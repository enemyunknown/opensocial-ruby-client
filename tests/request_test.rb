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

require File.dirname(__FILE__) + '/test_helper.rb'

class RequestTest < Test::Unit::TestCase #:nodoc:
  include TestHelper
  
  # Tests that a request properly throws an exception when a valid connection
  # doesn't exist
  def test_invalid_connection
    request = OpenSocial::FetchPersonRequest.new
    assert_raise OpenSocial::RequestException do
      request.send
    end
  end
  
  # Tests that send_request returns proper JSON
  def test_json_parsing
    # Test without unescaping data
    json = load_file('person.json')
    
    c = OpenSocial::Connection.new(NO_AUTH)
    request = OpenSocial::FetchPersonRequest.new(c)
    request.stubs(:dispatch).returns(json)
    person = request.send
    
    assert_equal OpenSocial::Person, person.class
    
    # Test with unescaping data
    json = load_file('appdata.json')
    
    c = OpenSocial::Connection.new(NO_AUTH)
    request = OpenSocial::FetchAppDataRequest.new(c)
    request.stubs(:dispatch).returns(json)
    appdata = request.send
    
    assert_equal OpenSocial::Collection, appdata.class
  end
end