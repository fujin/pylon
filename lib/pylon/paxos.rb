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

require 'celluloid'
require 'celluloid/group'
require 'celluloid/zmq'

class Pylon
  module Paxos

    class Server
      include Celluloid::ZMQ

      # Bind to the given 0MQ address (in URL form ala tcp://host:port)
      def initialize
        @addr   = Pylon::Config[:paxos_addr]
        @socket = Pylon::Paxos.zmq_context.socket(::ZMQ::PULL)

        unless ::ZMQ::Util.resultcode_ok? @socket.setsockopt(::ZMQ::LINGER, 0)
          @socket.close
          raise "couldn't set ZMQ::LINGER: #{::ZMQ::Util.error_string}"
        end

        unless ::ZMQ::Util.resultcode_ok? @socket.bind(@addr)
          @socket.close
          raise "couldn't bind to #{@addr}: #{::ZMQ::Util.error_string}"
        end

        run!
      end

      # Wait for incoming 0MQ messages
      def run
        while true
          wait_readable @socket
          message = ''

          rc = @socket.recv_string message
          if ::ZMQ::Util.resultcode_ok? rc
            handle_message message
          else
            raise "error receiving ZMQ string: #{::ZMQ::Util.error_string}"
          end
        end
      end

      # Shut down the server
      def finalize
        @socket.close if @socket
      end

      # Handle incoming messages
      def handle_message(message)
        begin
          message = decode_message message
        rescue InvalidMessageError => ex
          Celluloid::Logger.warn("couldn't decode message: #{ex.class}: #{ex}")
          return
        end

        begin
          message.dispatch
        rescue Exception => ex
          Celluloid::Logger.crash("DCell::Server: message dispatch failed", ex)
        end
      end

      class InvalidMessageError < StandardError; end # undecodable message

      # Decode incoming messages
      def decode_message(message)
        if message[0..1].unpack("CC") == [Marshal::MAJOR_VERSION, Marshal::MINOR_VERSION]
          begin
            Marshal.load message
          rescue => ex
            raise InvalidMessageError, "invalid message: #{ex}"
          end
        else raise InvalidMessageError, "couldn't determine message format: #{message}"
        end
      end

      # Terminate this server
      def terminate
        @socket.close
        super
      end
    end

    class Group < Celluloid::Group
      supervise Server, :as => :pylon_paxos_server
    end

    class << self
      def zmq_context
        @zmq_context ||= Celluloid::ZMQ.context = ::ZMQ::Context.new(1)
      end

      def start
        Group.run!
      end

    end

  end
end
