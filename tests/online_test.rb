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

class OnlineTest < Test::Unit::TestCase #:nodoc:
  include TestHelper
  
  # Tests a simple REST request
  def test_online_rest
    consumer_key = 'orkut.com:623061448914'
    consumer_secret = 'uynAeXiWTisflWX99KU1D2q5'
    requestor = '03067092798963641994'
    c = OpenSocial::Connection.new(:consumer_key => consumer_key, :consumer_secret => consumer_secret, :xoauth_requestor_id => requestor)
    r = OpenSocial::FetchPersonRequest.new(c)
    person = r.send
    
    assert_equal OpenSocial::Person, person.class
  end
  
  # Tests a simple RPC request
  def test_online_rpc
    consumer_key = 'orkut.com:623061448914'
    consumer_secret = 'uynAeXiWTisflWX99KU1D2q5'
    requestor = '03067092798963641994'
    c = OpenSocial::Connection.new(:consumer_key => consumer_key, :consumer_secret => consumer_secret, :xoauth_requestor_id => requestor)
    r = OpenSocial::RpcRequest.new(c)
    r.add(:data => OpenSocial::FetchAppDataRequest.new)
    data = r.send[:data]
    
    assert_equal OpenSocial::Collection, data.class
  end
  
  # Test an unauthorized REST request
  def test_unauthorized_rest_request
    consumer_key = 'foo'
    consumer_secret = 'bar'
    requestor = 'baz'
    c = OpenSocial::Connection.new(:consumer_key => consumer_key, :consumer_secret => consumer_secret, :xoauth_requestor_id => requestor)
    r = OpenSocial::FetchPersonRequest.new(c)
    assert_raise OpenSocial::AuthException do
      person = r.send
    end
  end
  
  # Test an unauthorized RPC request
  def test_unauthorized_rpc_request
    consumer_key = 'foo'
    consumer_secret = 'bar'
    requestor = 'baz'
    c = OpenSocial::Connection.new(:consumer_key => consumer_key, :consumer_secret => consumer_secret, :xoauth_requestor_id => requestor)
    r = OpenSocial::RpcRequest.new(c)
    r.add(:data => OpenSocial::FetchAppDataRequest.new)
    assert_raise OpenSocial::AuthException do
      data = r.send[:data]
    end
  end
end