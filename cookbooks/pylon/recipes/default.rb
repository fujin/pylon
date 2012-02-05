#
# Cookbook Name:: pylon
# Recipe:: default
#
# Copyright 2011, AJ Christensen
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
#

# we shouldn't need to require dcell, celluloid, or anything. should
# already be loaded.

class Test
  include Celluloid

  def test
    true
  end
end

class TestGroup < Celluloid::Group
  supervise Test, :as => :test_class
end

log "testing pylon"

ruby_block "supervise test class" do
  block do
    TestGroup.run!
  end
end

