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

require_relative "config"
require_relative "log"
require_relative "command"

require "celluloid"
require "celluloid/group"
require "dcell"
require "dcell/server"
require "dcell/registries/zk_adapter"
require "uuidtools"
require "timeout"

class Pylon
  class DCell

    class Group < Celluloid::Group

      class TimeServer
        include Celluloid
        def time; "The time is: #{Time.now}"; end
      end

      class TimeClient
        include Celluloid

        def initialize
          Timeout::timeout(10) do
            ::DCell::Node.all.each do |node|

              if node.actors.include? :time_server
                Log.info "#{self}: time: #{node[:time_server].time}"
              end

            end
          end
        end
      end

      supervise TimeServer, :as => :time_server
      supervise TimeClient, :as => :time_client
    end

    attr_reader :dcell, :options
    def options
      Pylon::Config[:dcell_id] ||= UUIDTools::UUID.timestamp_create

      {:id => Pylon::Config[:dcell_id], :addr => Pylon::Config[:dcell_addr],
        :registry => {
          :adapter => Pylon::Config[:dcell_registry_adapter],
          :server => Pylon::Config[:dcell_registry_server],
          :port => Pylon::Config[:dcell_registry_port],
          :password => Pylon::Config[:dcell_registry_password]
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

      output = Group.run!

      loop do
        Log.info "#{self}: dcell nodes #{::DCell::Node.all}"
        Log.info "#{self}: dcell me #{::DCell.me}"
        Log.info "#{self}: dcell actors on me #{::DCell.me.actors.inspect}"
        Log.info "sleeping 30"
        sleep 30
      end

    end
  end
end # Pylon