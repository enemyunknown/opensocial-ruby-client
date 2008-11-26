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
  
  # Acts as a wrapper for an OpenSocial activity.
  #
  # The Activity class takes input JSON as an initialization parameter, and
  # iterates through each of the key/value pairs of that JSON. For each key
  # that is found, an attr_accessor is constructed, allowing direct access
  # to the value. Each value is stored in the attr_accessor, either as a
  # String, Fixnum, Hash, or Array.
  #
  
  
  class Activity < Base
    def initialize(json)
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
  
  # Provides the ability to request a collection of activities for a given
  # user or set of users.
  #
  # The FetchActivitiesRequest wraps a simple request to an OpenSocial
  # endpoint for a collection of activities. As parameters, it accepts
  # a user ID and selector (and optionally an ID of a particular activity).
  # This request may be used, standalone, by calling send, or bundled into
  # an RPC request.
  #
  
  
  class FetchActivitiesRequest < Request
    SERVICE = 'activities'
    
    # This is only necessary because of a spec inconsistency
    RPC_SERVICE = 'activity'
    
    def initialize(connection = nil, guid = '@me', selector = '@self',
                   pid = nil)
      super
    end
    
    def send
      json = send_request(SERVICE, @guid, @selector, @pid)

      return parse_response(json['entry'])
    end
    
    def parse_rpc_response(response)
      return parse_response(response['data']['list'])
    end
    
    def to_json(*a)
      value = {
        'method' => RPC_SERVICE + GET,
        'params' => {
          'userId' => ["#{@guid}"],
          'groupId' => "#{@selector}",
          'appId' => "#{@pid}"
        },
        'id' => @key
      }.to_json(*a)
    end
    
    private
    
    def parse_response(response)
      activities = Collection.new
      for entry in response
        activity = Activity.new(entry)
        activities[activity.id] = activity
      end
      
      return activities
    end
  end
end