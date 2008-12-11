# Copyright (c) 2008 Google Inc.
# 
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s| 
  s.name = 'opensocial'
  s.version = '0.0.2'
  s.author = 'Dan Holevoet'
  s.email = 'api.dwh@google.com'
  s.homepage = 'http://code.google.com/p/opensocial-ruby-client/'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Provides wrapper functionality and authentication for REST ' +
              'and RPC HTTP requests to OpenSocial-compliant endpoints, ' +
              'along with validation of incoming signed makeRequest calls.'
  s.files = FileList['lib/*.rb', 'lib/**/*.rb', 'lib/**/**/*.rb', 'tests/*.rb', 'tests/fixtures/*.json'].to_a
  s.require_path = 'lib'
  s.test_files = FileList['tests/test.rb']
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE', 'NOTICE']
  s.rdoc_options << '--main' << 'README'
  s.add_dependency('json', '>= 1.1.3')
  s.add_dependency('oauth', '>= 0.2.7')
  s.add_dependency('mocha', '>= 0.9.2')
  s.add_dependency('rails', '>= 2.1.0')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true 
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
  puts 'generated latest version'
end

task :test do
  ruby 'tests/test.rb'
end