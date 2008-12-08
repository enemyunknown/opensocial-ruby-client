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

require 'net/http'
require 'uri'

# Use json/pure if you opt-out of including the validation code in
# opensocial/auth. This gem adds standard to_json behavior for the
# request classes, instead of using ActiveSupport.
require 'rubygems'
require 'json/add/rails'


module OpenSocial #:nodoc:
  
  # Provides base functionality for the OpenSocial child classes.
  #
  
  
  class Base
    
    # Creates an attr_accessor for the specified variable name.
    def add_attr(name)
      self.class.class_eval "attr_accessor :#{name}"
    end
  end
  
  # Wraps the functionality of an OpenSocial collection as defined by the
  # specification. In practical uses, a Collection serves as a Hash (usually
  # index by ID) with the added benefit of being convertable to an Array, when
  # it's necessary to iterate over all of the values.
  #
  
  
  class Collection < Hash
    
    # Converts the Collection to an Array by 
    def to_array
      values
    end
  end
end