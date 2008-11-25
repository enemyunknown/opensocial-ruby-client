# Copyright (c) 2008 Google Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'oauth/consumer'


module OpenSocial #:nodoc:
  
  # Describes a connection to an OpenSocial container, including the ability to
  # declare an authorization mechanism and appropriate credentials.
  #
  
  
  class Connection
    ORKUT = { :endpoint => 'http://sandbox.orkut.com/social',
              :rest => 'rest/',
              :rpc => 'rpc/' }
    IGOOGLE = { :endpoint => 'http://gmodules.com/api',
                :rest => '',
                :rpc => 'rpc' }
    MYSPACE = { :endpoint => 'http://api.myspace.com/v2',
                :rest => '',
                :rpc => '' }
    
    AUTH_HMAC = 0
    AUTH_ST = 1
    
    DEFAULT_OPTIONS = { :container => ORKUT,
                        :st => '',
                        :consumer_key => '',
                        :consumer_secret => '',
                        :consumer_token => OAuth::Token.new('', ''),
                        :xoauth_requestor_id => '',
                        :auth => AUTH_HMAC }
    
    attr_accessor :container
    attr_accessor :st
    attr_accessor :consumer_key, :consumer_secret, :consumer_token
    attr_accessor :xoauth_requestor_id
    attr_accessor :auth
    
    def initialize(options = {})
      options = DEFAULT_OPTIONS.merge(options)
      options.each do |key, value|
        self.send("#{key}=", value)
      end
      
      if @auth == AUTH_HMAC && !has_valid_hmac_triple?
        raise ArgumentError.new('Connection authentication is set to ' +
                                'HMAC-SHA1, but a valid consumer_key/' +
                                'secret and xoauth_requestor_id triple ' +
                                'was not supplied.')
      elsif @auth == AUTH_ST && @st.empty?
        raise ArgumentError.new('Connection authentication is set to ' +
                                'security token, but a security token was ' +
                                'not supplied.')
      elsif ![AUTH_HMAC, AUTH_ST].include?(@auth)
        raise ArgumentError.new('Connection authentication is set to an ' +
                                'unknown value.')
      end
    end
    
    def service_uri(service, guid, selector, pid)
      uri = [@container[:endpoint], service, guid, selector, pid].compact.
              join('/')
      
      if @auth == AUTH_HMAC
        uri << '?xoauth_requestor_id=' + @xoauth_requestor_id
      elsif @auth == AUTH_ST
        uri << '?st=' + self.st
      end
      URI.parse(uri)
    end
    
    private
    
    def has_valid_hmac_triple?
      return (!@consumer_key.empty? && !@consumer_secret.empty? &&
              !@xoauth_requestor_id.empty?)
    end
  end
end