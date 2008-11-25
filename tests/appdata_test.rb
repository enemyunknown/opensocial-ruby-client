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

class AppDataTest < Test::Unit::TestCase #:nodoc:
  include TestHelper
  
  def test_initialization
    json = load_json('appdatum.json')
    appdata = OpenSocial::AppData.new('test', json['entry']['example.org:34KJDCSKJN2HHF0DW20394'])
    
    assert_equal Fixnum, appdata.pokes.class
    assert_equal 3, appdata.pokes
    
    assert_equal String, appdata.last_poke.class
    assert_equal "2008-02-13T18:30:02Z", appdata.last_poke
  end
  
  def test_fetch_appdata_request
    json = load_json('appdata.json')
    
    c = OpenSocial::Connection.new(NO_AUTH)
    request = OpenSocial::FetchAppDataRequest.new(c)
    request.stubs(:send_request).returns(json)
    appdata = request.send
    
    # Check properties of the collection
    assert_equal OpenSocial::Collection, appdata.class
    assert_equal 2, appdata.length
    
    # Check properties of the first appdatum
    first = appdata['example.org:34KJDCSKJN2HHF0DW20394']
    assert_equal Fixnum, first.pokes.class
    assert_equal 3, first.pokes
    
    assert_equal String, first.last_poke.class
    assert_equal "2008-02-13T18:30:02Z", first.last_poke
    
    # Check properties of the second appdatum
    second = appdata['example.org:58UIDCSIOP233FDKK3HD44']
    assert_equal Fixnum, second.pokes.class
    assert_equal 2, second.pokes
    
    assert_equal String, second.last_poke.class
    assert_equal "2007-12-16T18:30:02Z", second.last_poke
  end
end