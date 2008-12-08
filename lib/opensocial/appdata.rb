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
    
    # Initializes the AppData entry based on the provided id and json fragment.
    # If no JSON is provided, an empty object (with only an ID) is created.
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
  
  # Provides the ability to request a Collection of AppData for a given
  # user or set of users.
  #
  # The FetchAppData wraps a simple request to an OpenSocial
  # endpoint for a Collection of AppData. As parameters, it accepts
  # a user ID and selector. This request may be used, standalone, by calling
  # send, or bundled into an RpcRequest.
  #
  
  
  class FetchAppDataRequest < Request
    # Defines the service fragment for use in constructing the request URL or
    # JSON
    SERVICE = 'appdata'
    
    # Initializes a request to fetch appdata for the specified user and
    # group, or the default (@me, @self). A valid Connection is not necessary
    # if the request is to be used as part of an RpcRequest.
    def initialize(connection = nil, guid = '@me', selector = '@self',
                   aid = '@app')
      super(connection, guid, selector, aid)
    end
    
    # Sends the request, passing in the appropriate SERVICE and specified
    # instance variables. Accepts an unescape parameter, defaulting to true,
    # if the returned data should be unescaped.
    def send(unescape = true)
      json = send_request(SERVICE, @guid, @selector, @pid, unescape)

      return parse_response(json['entry'])
    end
    
    # Selects the appropriate fragment from the JSON response in order to
    # create a native object.
    def parse_rpc_response(response)
      return parse_response(response['data'])
    end
    
    # Converts the request into a JSON fragment that can be used as part of a
    # larger RpcRequest.
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
    
    # Converts the JSON response into a Collection of AppData entries, indexed
    # by id.
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