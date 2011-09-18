#
# Author:: AJ Christensen (<aj@junglist.gen.nz>)
# Copyright:: Copyright (c) 2011 AJ Christensen
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
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or#implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require "mixlib/config"

class Pylon
  class Config
    extend Mixlib::Config

    config_file "~/.pylon.rb"
    log_level :info
    log_location STDOUT
    daemonize false
    user nil
    group nil
    umask 0022

    # Options for the multicast server
    multicast true
    multicast_address "225.4.5.6"
    multicast_port "13336"
    multicast_ttl 3
    multicast_listen_address nil
    multicast_loopback false
    interface_address "127.0.0.1"

    # TCP settings
    tcp_address "*"
    tcp_port "13335"
    tcp_retries 10
    tcp_timeout 5

    # cluster settings
    maximum_weight 1000
    cluster_name "pylon"
    Seed_tcp_endpoints []
    master nil
    minimum_master_nodes 1
    sleep_after_announce 5

    # TODO: not implemented
    fd_interval 30
    fd_timeout 30
    fd_retries 3

  end
end
