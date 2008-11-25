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

class ActivityTest < Test::Unit::TestCase #:nodoc:
  include TestHelper
  
  def test_initialization
    json = load_json('activity.json')
    activity = OpenSocial::Activity.new(json['entry'])
    
    assert_equal 'http://example.org/activities/example.org:87ead8dead6beef/self/af3778', activity.id
    assert_equal String, activity.id.class
    
    assert_equal Hash, activity.title.class
    assert_equal 'html', activity.title['type']
    assert_equal '<a href="foo">some activity</a>', activity.title['value']
    
    assert_equal String, activity.updated.class
    assert_equal '2008-02-20T23:35:37.266Z', activity.updated
    
    assert_equal String, activity.body.class
    assert_equal 'Some details for some activity', activity.body
    
    assert_equal String, activity.body_id.class
    assert_equal '383777272', activity.body_id
    
    assert_equal String, activity.url.class
    assert_equal 'http://api.example.org/activity/feeds/.../af3778', activity.url
    
    assert_equal String, activity.user_id.class
    assert_equal 'example.org:34KJDCSKJN2HHF0DW20394', activity.user_id
  end
  
  def test_fetch_groups_request
    json = load_json('activities.json')
    
    c = OpenSocial::Connection.new(NO_AUTH)
    request = OpenSocial::FetchActivitiesRequest.new(c)
    request.stubs(:send_request).returns(json)
    activities = request.send
    
    # Check properties of the collection
    assert_equal OpenSocial::Collection, activities.class
    assert_equal 2, activities.length
    
    # Check properties of the first activity
    first = activities['http://example.org/activities/example.org:87ead8dead6beef/self/af3778']
    assert_equal 'http://example.org/activities/example.org:87ead8dead6beef/self/af3778', first.id
    assert_equal String, first.id.class
    
    assert_equal Hash, first.title.class
    assert_equal 'html', first.title['type']
    assert_equal '<a href="foo">some activity</a>', first.title['value']
    
    assert_equal String, first.updated.class
    assert_equal '2008-02-20T23:35:37.266Z', first.updated
    
    assert_equal String, first.body.class
    assert_equal 'Some details for some activity', first.body
    
    assert_equal String, first.body_id.class
    assert_equal '383777272', first.body_id
    
    assert_equal String, first.url.class
    assert_equal 'http://api.example.org/activity/feeds/.../af3778', first.url
    
    assert_equal String, first.user_id.class
    assert_equal 'example.org:34KJDCSKJN2HHF0DW20394', first.user_id
    
    # Check properties of the second activity
    second = activities['http://example.org/activities/example.org:87ead8dead6beef/self/af3779']
    assert_equal 'http://example.org/activities/example.org:87ead8dead6beef/self/af3779', second.id
    assert_equal String, second.id.class
    
    assert_equal Hash, second.title.class
    assert_equal 'html', second.title['type']
    assert_equal '<a href="foo">some activity</a>', second.title['value']
    
    assert_equal String, second.updated.class
    assert_equal '2008-02-20T23:35:38.266Z', second.updated
    
    assert_equal String, second.body.class
    assert_equal 'Some details for some second activity', second.body
    
    assert_equal String, second.body_id.class
    assert_equal '383777273', second.body_id
    
    assert_equal String, second.url.class
    assert_equal 'http://api.example.org/activity/feeds/.../af3779', second.url
    
    assert_equal String, second.user_id.class
    assert_equal 'example.org:34KJDCSKJN2HHF0DW20394', second.user_id
  end
end