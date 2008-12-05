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


module OpenSocial #:nodoc:
  
  # Acts as a wrapper for an OpenSocial appdata entry.
  #
  # The AppData class takes a person's ID and input JSON as initialization
  # parameters, and iterates through each of the key/value pairs of that JSON.
  # For each key that is found, an attr_accessor is constructed (except for
  # :id which is preconstructed, and required), allowing direct access to the
  # value. Each value is stored in the attr_accessor, either as a String,
  # Fixnum, Hash, or Array.
  #
  
  
  class AppData < Base
    attr_accessor :id
    
    def initialize(id, json)
      @id = id
      
      if json
        json.each do |key, value|
          begin
            self.send("#{key}=", value)
          rescue NoMethodError
            add_attr(key)
            self.send("#{key}=", value)
          end
        end
      end
    end
  end
  
  # Provides the ability to request a collection of appdata for a given
  # user or set of users.
  #
  # The FetchAppData wraps a simple request to an OpenSocial
  # endpoint for a collection of appdata. As parameters, it accepts
  # a user ID and selector. This request may be used, standalone, by calling
  # send, or bundled into an RPC request.
  #
  
  
  class FetchAppDataRequest < Request
    SERVICE = 'appdata'
    
    def initialize(connection = nil, guid = '@me', selector = '@self',
                   aid = '@app')
      super(connection, guid, selector, aid)
    end
    
    def send(unescape = true)
      json = send_request(SERVICE, @guid, @selector, @pid, unescape)

      return parse_response(json['entry'])
    end
    
    def parse_rpc_response(response)
      return parse_response(response['data'])
    end
    
    def to_json(*a)
      value = {
        'method' => SERVICE + GET,
        'params' => {
          'userId' => ["#{@guid}"],
          'groupId' => "#{@selector}",
          'appId' => "#{@pid}",
          'fields' => []
        },
        'id' => @key
      }.to_json(*a)
    end
    
    private
    
    def parse_response(response)
      appdata = Collection.new
      response.each do |key, value|
        data = AppData.new(key, value)
        appdata[key] = data
      end
      
      return appdata
    end
  end
end