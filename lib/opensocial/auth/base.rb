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

require 'rubygems'
require 'oauth'
require 'oauth/consumer'


module OpenSocial #:nodoc:
  
  # Provides helper classes to be used in verifying and validating the user.
  # In particular, support is provided for:
  # 
  # * Verification of signed makeRequest using OAuth/HMAC-SHA1
  #   class ExampleController < ApplicationController
  #     OpenSocial::Auth::CONSUMER_KEY = '623061448914'
  #     OpenSocial::Auth::CONSUMER_SECRET = 'uynAeXiWTisflWX99KU1D2q5'
  #     
  #     include OpenSocial::Auth
  #   
  #     before_filter :validate
  #   
  #     def return_private_data
  #     end
  #   end
  #
  # * Request for an OAuth request token
  #
  # * Request for an OAuth access token, when supplied with a request token
  #
  
  
  module Auth
    
    # Validates an incoming request by using the OAuth library and the supplied
    # key and secret.
    def validate(key = CONSUMER_KEY, secret = CONSUMER_SECRET)
      consumer = OAuth::Consumer.new(key, secret)
      begin
        signature = OAuth::Signature.build(request) do
          [nil, consumer.secret]
        end
        pass = signature.verify
      rescue OAuth::Signature::UnknownSignatureMethod => e
        logger.error 'An unknown signature method was supplied: ' + e.to_s
      end
      return pass
    end
    
    # Gets an OAuth request token, and redirects the user to authorize the app
    # to access data on their behalf.
    def get_oauth_token(key, secret, container, callback)
      consumer = OAuth::Consumer.new(key, secret, {
        :site => container[:base_uri],
        :request_token_path => container[:request_token_path],
        :authorize_path => container[:authorize_path],
        :access_token_path => container[:access_token_path],
        :http_method => container[:http_method]
      })
      request_token = consumer.get_request_token
      
      session[:token] = request_token.token
      session[:secret] = request_token.secret
      
      redirect_to request_token.authorize_url + '&oauth_callback=' + CGI.escape(callback)
    end
    
    # If neccesary, swaps an existing request token and secret for an access
    # token, storing it in the Connection class, and returning the access token
    # and secret for later use.
    def get_access_token(connection, token, secret)
      if (token && secret)
        consumer = OAuth::Consumer.new(connection.consumer_key,
                                       connection.consumer_secret,
                                       connection.container)

        if connection.consumer_token.token.empty? &&
           connection.consumer_token.secret.empty?
          connection.consumer_token = OAuth::Token.new(token, secret)

          uri = URI.parse(connection.container[:base_uri] +
                          connection.container[:access_token_path])
          http = Net::HTTP.new(uri.host)
          req = Net::HTTP::Get.new(uri.request_uri)
          connection.sign!(http, req)

          resp = http.get(req.path)

          matches = resp.body.match(/oauth_token=(.*?)&oauth_token_secret=(.*)/)
          access_token = matches[1]
          access_secret = matches[2]
        end

        reusable_token = OAuth::AccessToken.new(consumer, access_token, access_secret)
        connection.consumer_token = reusable_token

        return access_token, access_secret
      end
      
      return nil, nil
    end
  end
end