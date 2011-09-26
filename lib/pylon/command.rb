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
require_relative "log"
require_relative "exceptions"
class Pylon
  class Command

    attr_reader :description

    def initialize(description)
      Log.info "command: #{description} initialized"
      @description = description
    end

    def execute
      raise Pylon::Exceptions::UndefinedCommand, "you must override the execute method"
    end
  end # Command
end # Pylon

# Expects a two element tuple containing a string command and a
# hash of params:
# ["command", :params => {}]
# def handle_command string
#   command, params = JSON.parse(string)
#   case command
#   when "deploy"
#     Log.info "handle_command: deploy command received"
#     deploy(params)
#   when "sync_time"
#     Log.info "handle_command: sync time received, running ntpdate"
#     ["sync_time", %x{ntpdate -u pool.ntp.org}]
#   when "add"
#     Log.info "handle_command: add message received, params: #{params.inspect}"
#   when "new_leader"
#     Log.info "handle_command: new_leader message received"
#     new_leader = params
#     new_leader.send "add", self
#     self
#   when "status"
#     Log.info "handle_command: status message received, sending node back"
#     self
#   when "ping"
#     timestamp = Time.now.to_i
#     Log.info "handle_command: ping requested, sending pong with timestamp: #{timestamp}"
#     ["pong", timestamp]
#   when "exit"
#     error = "handle_command: exit command received"
#     error << " with message: #{params["message"]}" if params.has_key? "message"
#     Pylon::Application.fatal! error, 1
#   else
#     Pylon::Application.fatal! "handle_command: unrecognized command '#{command.inspect}' (params: #{params.inspect}), exiting!", -99
#   end
# end

require_relative "application"
class Pylon
  class Command
    # Built in commands
    class Status < Command
      def initialize(node)
        super "status: #{node}"
        @node = node
      end

      def execute
        [ "status", @node.to_json ]
      end
    end # Status

    class Ping < Command
      def initialize(timestamp = Time.now.to_i)
        super "ping: #{timestamp}"
        @timestamp = timestamp
      end

      def execute
        [ "ping", @timestamp ]
      end
    end # Ping

    class Exit < Command
      def initialize(message)
        super "exit: #{message}"
        @message = message
      end

      def execute
        Pylon::Application.fatal! @message, 1
      end
    end # Exit


    class Deploy < Command
    end


    class Add < Command
    end

    class NewLeader < Command
    end

  end # Command
end # Pylon
