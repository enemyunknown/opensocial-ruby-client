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
                :rpc => '',
                :base_uri => 'http://api.myspace.com',
                :request_token_path => '/request_token',
                :authorize_path => '/authorize',
                :access_token_path => '/access_token',
                :http_method => :get }
    
    AUTH_HMAC = 0
    AUTH_ST = 1
    
    DEFAULT_OPTIONS = { :container => ORKUT,
                        :st => '',
                        :consumer_key => '',
                        :consumer_secret => '',
                        :consumer_token => OAuth::Token.new('', ''),
                        :xoauth_requestor_id => '',
                        :auth => AUTH_HMAC }
    
    # Defines the container that will be used in requests.
    attr_accessor :container
    
    # Defines the security token, for when OAuth is not in use.
    attr_accessor :st
    
    # Defines the consumer key for OAuth.
    attr_accessor :consumer_key
    
    # Defines the consumer secret for OAuth.
    attr_accessor :consumer_secret
    
    # Defines the consumer token for OAuth.
    attr_accessor :consumer_token
    
    # Defines the ID of the requestor (required by some implementations when
    # using OAuth).
    attr_accessor :xoauth_requestor_id
    
    # Defines the authentication scheme: HMAC or security token.
    attr_accessor :auth
    
    # Initializes the Connection using the supplied options hash, or the
    # defaults. Verifies that the supplied authentication type has proper
    # (ie. non-blank) credentials, and that the authentication type is known.
    def initialize(options = {})
      options = DEFAULT_OPTIONS.merge(options)
      options.each do |key, value|
        self.send("#{key}=", value)
      end
      
      if @auth == AUTH_HMAC && !has_valid_hmac_double?
        raise ArgumentError.new('Connection authentication is set to ' +
                                'HMAC-SHA1, but a valid consumer_key and' +
                                'secret pair was not supplied.')
      elsif @auth == AUTH_ST && @st.empty?
        raise ArgumentError.new('Connection authentication is set to ' +
                                'security token, but a security token was ' +
                                'not supplied.')
      elsif ![AUTH_HMAC, AUTH_ST].include?(@auth)
        raise ArgumentError.new('Connection authentication is set to an ' +
                                'unknown value.')
      end
    end
    
    # Constructs a URI to the OpenSocial endpoint given a service, guid,
    # selector, and pid.
    def service_uri(service, guid, selector, pid)
      uri = [@container[:endpoint], service, guid, selector, pid].compact.
              join('/')
      
      if @auth == AUTH_HMAC && !xoauth_requestor_id.empty?
        uri << '?xoauth_requestor_id=' + @xoauth_requestor_id
      elsif @auth == AUTH_ST
        uri << '?st=' + self.st
      end
      URI.parse(uri)
    end
    
    # Signs a request using OAuth.
    def sign!(http, req)
      if @auth == AUTH_HMAC
        consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret)
        req.oauth!(http, consumer, @consumer_token, :scheme => 'query_string')
      end
    end
    
    private
    
    # Verifies that the consumer key, consumer secret and requestor id are all
    # non-blank.
    def has_valid_hmac_double?
      return (!@consumer_key.empty? && !@consumer_secret.empty?)
    end
  end
end