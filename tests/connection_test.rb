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

class ConnectionTest < Test::Unit::TestCase #:nodoc:
  include TestHelper
  
  # Tests that a connection properly throws an exception invalid parameters are
  # supplied
  def test_invalid_connection_parameters
    non_blank = 'foo'
    
    pass_invalid_hmac_parameters(non_blank, '', '')
    pass_invalid_hmac_parameters('', non_blank, '')
    pass_invalid_hmac_parameters('', '', non_blank)
    
    assert_nothing_raised ArgumentError do
      c = OpenSocial::Connection.new(:consumer_key => non_blank,
                                     :consumer_secret => non_blank,
                                     :xoauth_requestor_id => '')
    end
    
    assert_raise ArgumentError do
      c = OpenSocial::Connection.new(:auth => OpenSocial::Connection::AUTH_ST,
                                     :st => '')
    end
    
    assert_raise ArgumentError do
      c = OpenSocial::Connection.new(:auth => 1234124)
    end
  end
  
  private
  
  def pass_invalid_hmac_parameters(key, secret, id)
    assert_raise ArgumentError do
      c = OpenSocial::Connection.new(:consumer_key => key,
                                     :consumer_secret => secret,
                                     :xoauth_requestor_id => id)
    end
  end
end