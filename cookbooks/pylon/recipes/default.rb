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

execute "apt-get update"
package "zeromq"
package "build-essential"

execute "rsync -avu --progress --delete /vagrant/ /srv/pylon/" do
  notifies :delete, "directory[/srv/pylon/vendor/bundle]"
  notifies :run, "execute[bundle]"
end

directory "/srv/pylon/vendor/bundle" do
  action :nothing
  recursive true
end

execute "bundle" do
  command "bundle install --deployment"
  cwd "/srv/pylon"
  user "vagrant"
  group "vagrant"
  action :nothing
end


