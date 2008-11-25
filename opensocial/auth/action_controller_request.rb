# Copyright (c) 2007 Blaine Cook, Larry Halff, Pelle Braendgaard
#  
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#  
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#  
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Includes modifications by Robin Luckey from:
# http://github.com/robinluckey/oauth/tree/master/lib%2Foauth%2Frequest_proxy%2Faction_controller_request.rb

require 'rubygems'
require 'active_support'
require 'action_controller/request'
require 'oauth/request_proxy/base'
require 'uri'

module OAuth::RequestProxy #:nodoc: all
  class ActionControllerRequest < OAuth::RequestProxy::Base
    proxies ActionController::AbstractRequest
 
    def method
      request.method.to_s.upcase
    end
 
    def uri
      uri = URI.parse(request.protocol + request.host + request.port_string + request.path)
      uri.query = nil
      uri.to_s
    end
    
    def parameters
      if options[:clobber_request]
        options[:parameters] || {}
      else
        params = request_params.merge(query_params).merge(header_params)
        params.stringify_keys! if params.respond_to?(:stringify_keys!)
        params.merge(options[:parameters] || {})
      end
    end
    
    # Override from OAuth::RequestProxy::Base to avoid roundtrip
    # conversion to Hash or Array and thus preserve the original
    # parameter names
    def parameters_for_signature
      params = []
      params << options[:parameters].to_query if options[:parameters]
 
      unless options[:clobber_request]
        params << header_params.to_query
        params << CGI.unescape(request.query_string) unless request.query_string.blank?
        if request.content_type == Mime::Type.lookup("application/x-www-form-urlencoded")
          params << CGI.unescape(request.raw_post)
        end
      end

      params.
        join('&').split('&').
        reject { |kv| kv =~ /^oauth_signature=.*/}.
        reject(&:blank?).
        map { |p| p.split('=') }
    end
 
    protected
 
    def query_params
      request.query_parameters
    end
 
    def request_params
      request.request_parameters
    end
 
  end
end