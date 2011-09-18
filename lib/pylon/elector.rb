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
require "uuidtools"
require "ffi-rzmq"
require "thread"
require "json"
require_relative "node"

class Pylon
  class Elector

    attr_accessor :cluster_name, :context, :multicast_endpoint, :node, :nodes, :multicast_announcer_thread, :multicast_listener_thread, :tcp_listener_thread, :master

    def initialize
      @cluster_name = Pylon::Config[:cluster_name]
      @context = ZMQ::Context.new(1)

      @node = Pylon::Node.new
      @nodes = Array(@node)
      @master = Pylon::Config[:master]

      Pylon::Log.info "elector[#{cluster_name}] initialized, starting pub/sub sockets on #{multicast_endpoint} and tcp listener socket on #{node.unicast_endpoint}"

      Thread.abort_on_exception = true
      
      scheduler = Thread.new do
        @unicast_announcer_thread = node.unicast_announcer
        @multicast_announcer_thread = node.multicast_announcer
        @multicast_listener_thread = multicast_listener

        @multicast_listener_thread.join
        @unicast_announcer_thread.join
        @multicast_announcer_thread.join
      end
      scheduler.join

      # join listeners
      # @unicast_announcer_thread.join
      # @tcp_listener_thread.join
      # sleep 5
      # @multicast_announcer_thread.join

      at_exit do
        Log.debug "cleaning up zeromq context"
        @context.terminate
      end
    end

    def stop_announcer
      @multicast_announcer_thread.stop
    end

    def run_announcer
      @multicast_announcer.thread.run
    end

    def pause_listeners
      @tcp_listener_thread.stop
      @multicast_listener_thread.stop
    end

    def run_listeners
      @tcp_listener_thread.run
      @multicst_listener_thread.run
    end

    def unicast_endpoint
      @unicast_endpoint ||= "tcp://#{Pylon::Config[:tcp_address]}:#{Pylon::Config[:tcp_port]}"
    end

    def multicast_endpoint
      @multicast_endpoint ||= "epgm://#{Pylon::Config[:interface]};#{Pylon::Config[:multicast_address]}:#{Pylon::Config[:multicast_port]}"
    end

    def add_node node
      @nodes << node unless @nodes.include? node
    end

    def multicast_listener
      Thread.new do
        Log.debug "multicast_listener: zeromq sub socket starting up on #{@multicast_endpoint}"
        sub_socket = context.socket ZMQ::SUB
        sub_socket.setsockopt ZMQ::IDENTITY, "node"
        sub_socket.setsockopt ZMQ::SUBSCRIBE, ""
        sub_socket.setsockopt ZMQ::RATE, 1000
        sub_socket.setsockopt ZMQ::MCAST_LOOP, Pylon::Config[:multicast_loopback]
        sub_socket.connect multicast_endpoint
        loop do
          uuid = sub_socket.recv_string
          Log.debug "multicast_listener: handling announce from #{uuid}"
          handle_announce sub_socket.recv_string if sub_socket.more_parts?
        end
      end
    end

    def allocate_master
      nodes.sort.each do |node|
        Log.debug "node: #{node}"
      end
      if node.uuid == nodes.sort.last.uuid
        @master = true
        Log.info "allocate_master: master allocated"
        nodes.each do |node|
          connect_node node.uuid.to_s, node.unicast_endpoint
        end
      else
        Log.info "allocate_master: someone else is the master, getting ready for work"
        @master = false
      end
    end

    def handle_announce recv_string
      Log.info "handle_announce: got string #{recv_string}"
      node = JSON.parse(recv_string)
      Log.info "handle_anounce: got announce from #{node}"
      if master
        Log.info "handle_announce: I am the master: updating #{node} of leadership status"
        connect_node(node.uuid.to_s, node.unicast_endpoint)
      elsif nodes.length < Pylon::Config[:minimum_master_nodes]
        if nodes.include? node
          Log.info "handle_announce: skipping node #{node}, already known"
          Log.debug "handle_announce: nodes: #{nodes}"
        else
          Log.info "handle_announce: subscribing for #{node} on endpoint: #{node.unicast_endpoint}"
          connect_node(node.uuid.to_s, node.unicast_endpoint)
        end
      else
        allocate_master
      end
    end

    def connect_node uuid, endpoint
      Log.debug "connect_node: subscribe socket connecting to #{endpoint}"
      sub_socket = context.socket ZMQ::SUB
      sub_socket.setsockopt ZMQ::IDENTITY, uuid
      sub_socket.setsockopt ZMQ::SUBSCRIBE, uuid
      sub_socket.connect endpoint
      uuid = sub_socket.recv_string
      Log.debug "connect_node: got uuid on sub socket, parsing node"
      new_node = JSON.parse(sub_socket.recv_string) if sub_socket.more_parts?
      Log.debug "connect_node: node: #{new_node}"
      if nodes.include? new_node
        Log.info "connect_node: skipping node #{new_node}, already in local list, sleeping for 60 secs"
        Log.debug "connect_node: nodes: #{nodes}"
        sleep 60
      else
        Log.info "connect_node: connected to node #{new_node}, adding to local list"
        add_node new_node
      end
    end
  end
end
