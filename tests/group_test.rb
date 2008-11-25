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

class GroupTest < Test::Unit::TestCase #:nodoc:
  include TestHelper
  
  # Tests construction of a group from a JSON entry
  def test_initialization
    json = load_json('group.json')
    group = OpenSocial::Group.new(json['entry'])
    
    assert_equal 'example.org:34KJDCSKJN2HHF0DW20394/friends', group.id
    assert_equal String, group.id.class
    
    assert_equal 'Peeps', group.title
    assert_equal String, group.title.class
    
    assert_equal Hash, group.link.class
    assert_equal 'alternate', group.link['rel']
    assert_equal 'http://api.example.org/people/example.org:34KJDCSKJN2HHF0DW20394/@friends', group.link['href']
  end
  
  def test_fetch_groups_request
    json = load_json('groups.json')
    
    c = OpenSocial::Connection.new(NO_AUTH)
    request = OpenSocial::FetchGroupsRequest.new(c)
    request.stubs(:send_request).returns(json)
    groups = request.send
    
    # Check properties of the collection
    assert_equal OpenSocial::Collection, groups.class
    assert_equal 2, groups.length
    
    # Check properties of the first group
    first = groups['example.org:34KJDCSKJN2HHF0DW20394/friends']
    assert_equal 'example.org:34KJDCSKJN2HHF0DW20394/friends', first.id
    assert_equal String, first.id.class
    
    assert_equal 'Peeps', first.title
    assert_equal String, first.title.class
    
    assert_equal Hash, first.link.class
    assert_equal 'alternate', first.link['rel']
    assert_equal 'http://api.example.org/people/example.org:34KJDCSKJN2HHF0DW20394/@friends', first.link['href']
    
    # Check properties of the second group
    second = groups['example.org:34KJDCSKJN2HHF0DW20394/family']
    assert_equal 'example.org:34KJDCSKJN2HHF0DW20394/family', second.id
    assert_equal String, second.id.class
    
    assert_equal 'Family', second.title
    assert_equal String, second.title.class
    
    assert_equal Hash, second.link.class
    assert_equal 'alternate', second.link['rel']
    assert_equal 'http://api.example.org/people/example.org:34KJDCSKJN2HHF0DW20394/@family', second.link['href']
  end
end