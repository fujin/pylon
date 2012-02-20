#
# Author:: AJ Christensen (<aj@junglist.gen.nz>)
# Copyright:: Copyright (c) 2012 AJ Christensen
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

require "celluloid"
require "celluloid/group"
require "dcell"
require "dcell/server"
require "uuidtools"
require "timeout"

class Pylon
  class DCell
    class Respawn < StandardError; end

    class ClusterStatus
      include Celluloid

      def initialize
        ::DCell::Node.all.each do |node|
          Log.info "#{current_actor}: dcell node: #{node.inspect}, actors: #{node.actors}"
        end
        Log.info "#{current_actor}: crashing in 35s for respawn"
        after(35) { raise Pylon::Exceptions::DCell::Respawn }
      end
    end

    class TimeClient
      include Celluloid

      def initialize
        Timeout::timeout(10) do
          ::DCell::Node.all.each do |node|
            if node.actors.include? :time_server
              Log.info "#{current_actor}: time: #{node[:time_server].time}"
            end
          end
        end
        after(35) { raise Pylon::Exceptions::DCell::Respawn }
      end
    end

    class TimeServer
      include Celluloid

      def time
        Log.info "#{current_actor}: got request for time"
        "The time is: #{Time.now}"
      end
    end

    attr_reader :dcell, :options
    def options
      Pylon::Config[:dcell_id] ||= UUIDTools::UUID.timestamp_create

      {"id" => Pylon::Config[:dcell_id], "addr" => Pylon::Config[:dcell_addr],
        "registry" => {
          "adapter" => Pylon::Config[:dcell_registry_adapter],
          "server" => Pylon::Config[:dcell_registry_server],
          "port" => Pylon::Config[:dcell_registry_port],
          "password" => Pylon::Config[:dcell_registry_password]
        }.reject! { |k,v| v.nil? } }
    end

    def setup_logging
      Celluloid.logger = Pylon::Log.logger
      Celluloid::Logger.info "#{self}: test celluloid logging into pylon"
    end

    def initialize
      setup_logging

      Log.debug "#{self}: options #{options.inspect}"

      Log.info "#{self}: starting DCell"
      @dcell = ::DCell.start options
      Log.info "#{self}: dcell started: #{dcell}"

      Class.new(Celluloid::Group) do
        supervise TimeServer, :as => :time_server
      end.run!

      Class.new(Celluloid::Group) do
        supervise TimeClient, :as => :time_client
        supervise ClusterStatus, :as => :cluster_status
      end

    end

  end
end # Pylon
