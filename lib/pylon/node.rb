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
require "uuidtools"
require "ffi-rzmq"
require "thread"
require "json"

class Pylon
  class Node

    attr_accessor :uuid, :weight, :timestamp, :context
    attr_reader :unicast_endpoint, :multicast_endpoint

    def initialize(json=nil)
      @context = ZMQ::Context.new(1)
    end

    def unicast_endpoint(arg=nil)
      if arg != nil
        @unicast_endpoint = arg
      else
        @unicast_endpoint ||= "tcp://#{Pylon::Config[:tcp_address]}:#{Pylon::Config[:tcp_port]}"
      end
    end

    def multicast_endpoint(arg=nil)
      if arg != nil
        @multicast_endpoint = arg
      else
        @multicast_endpoint ||= "epgm://#{Pylon::Config[:interface]};#{Pylon::Config[:multicast_address]}:#{Pylon::Config[:multicast_port]}"
      end
    end

    def weight(arg=nil)
      if arg != nil
        @weight = arg
      else
        @weight ||= (srand; rand * Pylon::Config[:maximum_weight] % Pylon::Config[:maximum_weight]).to_i
      end
    end

    def timestamp(arg=nil)
      if arg != nil
        @timestamp = arg
      else
        @timestamp ||= Time.now.to_i
      end
    end

    include Comparable
    def <=>(node)
      weight <=> node.weight
    end

    def uuid(arg=nil)
      if arg != nil
        @uuid = UUIDTools::UUID.parse(arg)
      else
        @uuid ||= random_uuid
      end
    end

    def random_uuid
      UUIDTools::UUID.timestamp_create
    end

    # Expects a two element tuple containing a string command and a
    # hash of params:
    # ["command", :params => {}]
    def handle_command string
      command, params = JSON.parse(string)
      case command
      when "add"
        Log.info "handle_command: add message received, params: #{params.inspect}"
      when "new_leader"
        Log.info "handle_command: new_leader message received"
        new_leader = params
        new_leader.send "add", self
        self
      when "status"
        Log.info "handle_command: status message received, sending node back"
        self
      when "ping"
        Log.info "handle_command: ping requested, sending pong"
        ["pong", Time.now.to_i]
      when "exit"
        Pylon::Application.fatal! "handle_command: exit command received", 1
      else
        Pylon::Application.fatal! "handle_command: unrecognized command '#{command}' (params: #{params}), exiting!", -99
      end
    end

    def send(command = "status", params = {})
      Thread.new do
        req_socket = context.socket ZMQ::REQ
        req_socket.setsockopt ZMQ::LINGER, 0
        req_socket.connect unicast_endpoint
        if req_socket.send_string "command", ZMQ::SNDMORE
          Log.debug "connect_node: sent command protocol initiator"
          if req_socket.send_string([command, params].to_json)
            response = JSON.parse(req_socket.recv_string)
          end
        end
        response
      end.value
    end

    def unicast_announcer
      Thread.new do
        Log.debug "unicast_announcer: zeromq pub socket announcer starting up on #{unicast_endpoint}"
        rep_socket = context.socket ZMQ::REP
        rep_socket.bind unicast_endpoint
        loop do
          if rep_socket.recv_string == "command"
            rep_socket.send_string handle_command(rep_socket.recv_string).to_json if rep_socket.more_parts?
          end
          sleep_after_announce = Pylon::Config[:sleep_after_announce]
          Log.debug "#{self}: unicast announcing then sleeping #{sleep_after_announce} secs"
          Thread.pass
          sleep sleep_after_announce
        end

      end
    end

    def multicast_announcer
      Thread.new do
        Log.debug "multicast_announcer: zeromq pub socket announcer starting up on #{multicast_endpoint}"
        pub_socket = context.socket ZMQ::PUB
        pub_socket.setsockopt ZMQ::IDENTITY, "node"
        pub_socket.setsockopt ZMQ::RATE, 1000
        pub_socket.setsockopt ZMQ::MCAST_LOOP, Pylon::Config[:multicast_loopback]
        pub_socket.connect multicast_endpoint
        loop do
          sleep_after_announce = Pylon::Config[:sleep_after_announce]
          Log.debug "#{self}: announcing then sleeping #{sleep_after_announce} secs"
          pub_socket.send_string uuid.to_s, ZMQ::SNDMORE
          pub_socket.send_string self.to_json
          Thread.pass
          sleep sleep_after_announce
        end
      end
    end

    def to_s
      "node[#{uuid}/#{weight}]"
    end

    def to_hash
      {
        "json_class" => self.class.name,
        "uuid" => @uuid,
        "weight" => @weight,
        "unicast_endpoint" => @unicast_endpoint,
        "timestamp" => Time.now.to_i
      }
    end

    def to_json(*a)
      to_hash.to_json(*a)
    end

    def self.json_create(json)
      Log.debug "json_create: trying to create pylon::node object from json: #{json}"
      node = new(json)
      node.uuid(json["uuid"])
      node.weight json["weight"]
      node.unicast_endpoint json["unicast_endpoint"]
      node.timestamp json["timestamp"]
      Log.debug "#{node}: created from json succesfully"
      node
    end

  end
end

