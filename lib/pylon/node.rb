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
require_relative "exceptions"
require_relative "command"

class Pylon
  class Node

    attr_accessor :uuid, :weight, :timestamp, :context, :master
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
        @multicast_endpoint ||= "epgm://#{Pylon::Config[:multicast_interface]};#{Pylon::Config[:multicast_address]}:#{Pylon::Config[:multicast_port]}"
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

    def ping
      Timeout::timeout(Pylon::Config[:ping_timeout]) do
        pong, timestamp = self.send "ping", :attempt => attempt
      end
    rescue Timeout::Error => e
      Log.warn "ping: timeout exceeded #{Pylon::Config[:fd_timeout]}"
      raise Pylon::Exceptions::Node::PingTimeout, e
    else
      time_difference = timestamp - Time.now.to_i
      if time_difference >= 600
        Log.warn "ping: received bad timestamp: #{timestamp}, time difference: #{time_difference}"
        raise Pylon::Exceptions::Node::BadTimestamp, timestamp
      else
        Log.debug "ping: received pong with good timestamp: #{timestamp}"
      end
    end


    def send(command = "status", options = {})
      Thread.new do
        req_socket = context.socket ZMQ::REQ
        req_socket.setsockopt ZMQ::LINGER, 0
        req_socket.connect unicast_endpoint
        if req_socket.send_string "command", ZMQ::SNDMORE
          req_socket.send_string command, ZMQ::SNDMORE
          req_socket.send_string options.to_json

          #
          # Since the response *may* contain arbitrary Node json, we
          # can't parse here.
          #
          response = req_socket.recv_string
          Log.debug "send response: #{response.inspect}"
        end
        req_socket.close
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
            command = rep_socket.recv_string if rep_socket.more_parts?
            args = JSON.parse(rep_socket.recv_string) if rep_socket.more_parts?
            Log.debug "unicast_announcer: handling command #{command} with args #{args}"
            rep_socket.send_string Pylon::Command.run(command, args)
          end
          # Sleep shouldn't be needed here, rep_socket.recv_string
          # should block.. right?
          # sleep Pylon::Config[:sleep_after_announce]
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
          pub_socket.send_string Pylon::Command.run("status", :node => self.to_json)
          sleep Pylon::Config[:sleep_after_announce]
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
      node = new(json)
      node.uuid(json["uuid"])
      node.weight json["weight"]
      node.unicast_endpoint json["unicast_endpoint"]
      node.timestamp json["timestamp"]
      node
    end

  end
end

