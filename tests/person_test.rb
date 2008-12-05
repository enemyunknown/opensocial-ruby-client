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

class PersonTest < Test::Unit::TestCase #:nodoc:
  include TestHelper
  
  # Tests construction of a person from a JSON entry
  def test_initialization
    json = load_json('person.json')
    person = OpenSocial::Person.new(json['entry'])
    
    assert_equal 'example.org:34KJDCSKJN2HHF0DW20394', person.id
    assert_equal String, person.id.class
    
    assert_equal Hash, person.name.class
    assert_equal 'Jane Doe', person.name['unstructured']
    assert_equal '', person.long_name
    
    assert_equal Hash, person.gender.class
    assert_equal '女性', person.gender['displayvalue']
    assert_equal 'FEMALE', person.gender['key']
    
    assert person.is_owner
    assert person.is_viewer
  end
  
  # Tests construction of a person from a stubbed HTTP request
  def test_fetch_person_request
    json = load_json('person.json')
    
    c = OpenSocial::Connection.new(NO_AUTH)
    request = OpenSocial::FetchPersonRequest.new(c)
    request.stubs(:send_request).returns(json)
    person = request.send
    
    assert_equal 'example.org:34KJDCSKJN2HHF0DW20394', person.id
    assert_equal String, person.id.class
    
    assert_equal Hash, person.name.class
    assert_equal 'Jane Doe', person.name['unstructured']
    assert_equal '', person.long_name
    
    assert_equal Hash, person.gender.class
    assert_equal '女性', person.gender['displayvalue']
    assert_equal 'FEMALE', person.gender['key']
    
    assert person.is_owner
    assert person.is_viewer
  end
  
  # Tests construction of a collection of people from a stubbed HTTP request
  def test_fetch_people_request
    json = load_json('people.json')
    
    c = OpenSocial::Connection.new(NO_AUTH)
    request = OpenSocial::FetchPeopleRequest.new(c)
    request.stubs(:send_request).returns(json)
    people = request.send
    
    # Check properties of the collection
    assert_equal OpenSocial::Collection, people.class
    assert_equal 2, people.length
    
    # Check properties of the first person
    first = people['example.org:34KJDCSKJN2HHF0DW20394']
    assert_equal 'example.org:34KJDCSKJN2HHF0DW20394', first.id
    assert_equal String, first.id.class
    
    assert_equal Hash, first.name.class
    assert_equal 'Jane Doe', first.name['unstructured']
    assert_equal '', first.long_name
    
    assert_equal Hash, first.gender.class
    assert_equal '女性', first.gender['displayvalue']
    assert_equal 'FEMALE', first.gender['key']
    
    assert first.is_owner
    assert first.is_viewer
    
    # Check properties of the second person
    second = people['example.org:34KJDCSKJN2HHF0DW20395']
    assert_equal 'example.org:34KJDCSKJN2HHF0DW20395', second.id
    assert_equal String, second.id.class
    
    assert_equal Hash, second.name.class
    assert_equal 'Jane Doe2', second.name['unstructured']
    assert_equal '', second.long_name
    
    assert_equal Hash, second.gender.class
    assert_equal '女性', second.gender['displayvalue']
    assert_equal 'FEMALE', second.gender['key']
    
    assert !second.is_owner
    assert !second.is_viewer
  end
end