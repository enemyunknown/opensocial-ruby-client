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

class RpcRequestTest < Test::Unit::TestCase #:nodoc:
  include TestHelper
  
  # Tests that a request properly throws an exception when an empty list of
  # requests is specified
  def test_empty_requests
    c = OpenSocial::Connection.new(NO_AUTH)
    request = OpenSocial::RpcRequest.new(c)
    assert_raise OpenSocial::RequestException do
      request.send
    end
  end
  
  # Tests object generation from a single (non-batched) stubbed HTTP request
  # using RPC
  def test_fetch_person_rpc_request
    json = load_file('person_rpc.json')
    
    c = OpenSocial::Connection.new(NO_AUTH)
    request = OpenSocial::RpcRequest.new(c)
    request.add(:me => OpenSocial::FetchPersonRequest.new)
    request.stubs(:dispatch).returns(json)
    response = request.send

    assert_equal Hash, response.class
    assert_equal 1, response.length
    assert response.has_key?(:me)
    
    compare_person(response[:me])
  end
  
  # Tests object generation from a batch stubbed HTTP request using RPC
  def test_fetch_person_and_appdata_request
    json = load_file('person_appdata_rpc.json')
    
    c = OpenSocial::Connection.new(NO_AUTH)
    request = OpenSocial::RpcRequest.new(c)
    request.add(:me => OpenSocial::FetchPersonRequest.new)
    request.add(:data => OpenSocial::FetchAppDataRequest.new)
    request.stubs(:dispatch).returns(json)
    response = request.send
    
    assert_equal Hash, response.class
    assert_equal 2, response.length
    assert response.has_key?(:me)
    assert response.has_key?(:data)
    
    compare_person(response[:me])
    
    appdata = response[:data]
    assert_equal OpenSocial::Collection, appdata.class
    assert_equal 1, appdata.length
    
    entry = appdata['orkut.com:242412']
    assert_equal Hash, entry.token.class
    assert_equal Hash, entry.token["hash"].class
    assert_equal String, entry.token["hash"]["key"].class
    assert_equal "value", entry.token["hash"]["key"]
    assert_equal Fixnum, entry.token["integer"].class
    assert_equal 1241, entry.token["integer"]
  end
  
  private
  
  def compare_person(person)
    assert_equal 'orkut.com:242412', person.id
    assert_equal String, person.id.class

    assert_equal Hash, person.name.class
    assert_equal 'Sample Testington', person.long_name
    assert_equal 'Sample', person.short_name
    
    assert_equal String, person.thumbnail_url.class
    assert_equal 'http://www.orkut.com/img/i_nophoto64.gif', person.thumbnail_url
    
    assert !person.is_owner
    assert person.is_viewer
  end
end