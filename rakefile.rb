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

require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s| 
  s.name = "OpenSocial"
  s.version = "0.0.1"
  s.author = "Dan Holevoet"
  s.email = "api.dwh@google.com"
  s.homepage = "http://opensocial.org"
  s.platform = Gem::Platform::RUBY
  s.summary = "Provides authentication, REST, and JSON-RPC utilities for interaction with OpenSocial-compliant servers."
  s.files = FileList['lib/*.rb', 'test/*'].to_a
  s.require_path = "lib"
  s.test_files = Dir.glob('tests/*.rb')
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  s.add_dependency("ruby-hmac", ">= 0.3.2")
  s.add_dependency("ruby-openid", ">= 1.1.4")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true 
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
  puts "generated latest version"
end

task :test do
  ruby 'tests/test.rb'
end