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
  
  # Provides verification of signed makeRequest using OAuth with HMAC-SHA1.
  #  class ExampleController < ApplicationController
  #    OpenSocial::Auth::CONSUMER_KEY = '623061448914'
  #    OpenSocial::Auth::CONSUMER_SECRET = 'uynAeXiWTisflWX99KU1D2q5'
  #   
  #    include OpenSocial::Auth
  #   
  #    before_filter :validate
  #   
  #    def return_private_data
  #    end
  #  end
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
  end
end