#
# Author:: AJ Christensen (<aj@opscode.com>)
# Author:: Mark Mzyk (mmzyk@opscode.com)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require "pylon/dcell"
require "pylon/application"

# Chef libs to launch chef-solo
require "chef"
require "chef/application/solo"
require "chef/config"

class Pylon::Application::SoloPylon < Chef::Application::Solo

  option :dcell_id,
  :long => "--dcell-id DCELL_ID",
  :description => "The ID to use for dcell communication",
  :required => true

  option :dcell_addr,
  :short => "-a DCELL_ADDR",
  :long => "--dcell-addr DCELL_ADDR",
  :description => "The tcp zeromq endpoint to use for dcell communication, e.g. tcp://0.0.0.0:1234",
  :default => "tcp://0.0.0.0:1234"

  option :dcell_registry_adapter,
  :long => "--dcell-registry-adapter DCELL_REGISTRY_ADAPTER",
  :description => "Which adapter DCell should use for its registry, either zk or redis -- zk only available on JRuby",
  :default => "redis",
  :required => true

  option :dcell_registry_server,
  :long => "--dcell-registry-server DCELL_REGISTRY_server",
  :description => "The host where the DCell registry is running",
  :default => "localhost",
  :required => true

  option :dcell_registry_PORT,
  :long => "--dcell-registry-port DCELL_REGISTRY_PORT",
  :description => "The port where the DCell registry is running",
  :default => 6379,
  :required => true

  option :dcell_registry_password,
  :long => "--dcell-registry-password DCELL_REGISTRY_PASSWORD",
  :description => "The password for the dcell registry, only used for Redis",
  :required => false

  def initialize
    self.class.options.merge!(Chef::Application::Solo.options)
    super
  end

  def setup_application
    Pylon::Config.merge!(config)
    Pylon::Log.logger = Chef::Log.logger
    super
  end

  def run_application
    Pylon::DCell.new
    super
  end
end
