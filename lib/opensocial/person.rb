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

# Extends the OpenSocial module, providing a wrapper for OpenSocial people.
#
#    Person:             Acts as a wrapper for an OpenSocial person.
#    FetchPersonRequest: Provides the ability to request a single person.
#    FetchPeopleRequest: Provides the ability to request a collection of people
#                        by describing their relationship to a single person.
#


module OpenSocial #:nodoc:
  
  # Acts as a wrapper for an OpenSocial person.
  #
  # The Person class takes input JSON as an initialization parameter, and
  # iterates through each of the key/value pairs of that JSON. For each key
  # that is found, an attr_accessor is constructed, allowing direct access
  # to the value. Each value is stored in the attr_accessor, either as a
  # String, Fixnum, Hash, or Array.
  #
  
  
  class Person < Base
    def initialize(json)
      if json
        json.each do |key, value|
          proper_key = key.snake_case
          begin
            self.send("#{proper_key}=", value)
          rescue NoMethodError
            add_attr(proper_key)
            self.send("#{proper_key}=", value)
          end
        end
      end
    end
    
    def long_name
      if @name && @name['givenName'] && @name['familyName']
        return @name['givenName'] + ' ' + @name['familyName']
      elsif @nickname
        return @nickname
      else
        return ''
      end
    end
    
    def short_name
      if @name && @name['givenName']
        return @name['givenName']
      elsif @nickname
        return @nickname
      else
        return ''
      end
    end
  end
  
  # Provides the ability to request a single person.
  #
  # The FetchPeopleRequests wraps a simple request to an OpenSocial
  # endpoint for a single person. As parameters, it accepts a user ID and
  # selector and optionally an ID of a particular person, in order to display
  # the user ID's view of that person. This request may be used, standalone,
  # by calling send, or bundled into an RPC request.
  #
  
  
  class FetchPersonRequest < Request
    SERVICE = 'people'
    
    def initialize(connection = nil, guid = '@me', selector = '@self')
      super
    end
    
    def send
      json = send_request(SERVICE, @guid, @selector)
      
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
          'groupId' => "#{@selector}"
        },
        'id' => @key
      }.to_json(*a)
    end
    
    private
    
    def parse_response(response)
      return Person.new(response)
    end
  end
  
  # Provides the ability to request a collection of people by describing their
  # relationship to a single person.
  #
  #  The FetchPeopleRequests wraps a simple request to an OpenSocial
  #  endpoint for a collection of people. As parameters, it accepts
  #  a user ID and selector. This request may be used, standalone, by calling
  #  send, or bundled into an RPC request.
  #
  
  
  class FetchPeopleRequest < Request
    SERVICE = 'people'
    
    def initialize(connection = nil, guid = '@me', selector = '@friends')
      super
    end
    
    def send
      json = send_request(SERVICE, @guid, @selector)
      
      return parse_response(json['entry'])
    end
    
    def parse_rpc_response(response)
      return parse_response(response['data']['list'])
    end
    
    def to_json(*a)
      value = {
        'method' => SERVICE + GET,
        'params' => {
          'userId' => ["#{@guid}"],
          'groupId' => "#{@selector}"
        },
        'id' => @key
      }.to_json(*a)
    end
    
    private
    
    def parse_response(response)
      people = Collection.new
      for entry in response
        person = Person.new(entry)
        people[person.id] = person
      end
      
      return people
    end
  end
end