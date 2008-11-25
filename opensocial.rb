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

$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))


require 'opensocial/auth/action_controller_request'
require 'opensocial/auth/validate'
require 'opensocial/string/merb_string'
require 'opensocial/string/os_string'
require 'opensocial/base'
require 'opensocial/connection'
require 'opensocial/request'
require 'opensocial/person'
require 'opensocial/appdata'
require 'opensocial/activity'
require 'opensocial/group'