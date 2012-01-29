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
require "uuidtools"
require "ffi-rzmq"
require "thread"
require "json"
require_relative "node"

class Pylon
  class Elector

    attr_accessor :cluster_name,
    :context,
    :multicast_endpoint,
    :node,
    :nodes,
    :multicast_announcer_thread,
    :multicast_listener_thread,
    :tcp_listener_thread

    def initialize
      @cluster_name = Pylon::Config[:cluster_name]
      @context = ZMQ::Context.new(1)

      @node = Pylon::Node.new
      @nodes = Array(@node)

      Pylon::Log.info "#{node} initialized, starting elector"
      Pylon::Log.info "elector[#{cluster_name}] initialized, starting pub/sub sockets on #{multicast_endpoint} and tcp listener socket on #{node.unicast_endpoint}"

      Thread.abort_on_exception = true


      if Pylon::Config[:multicast]
        @multicast_listener_thread = multicast_listener
        @multicast_announcer_thread = node.multicast_announcer.join
      end
      @unicast_announcer_thread = node.unicast_announcer.join


      at_exit do
        Log.debug "cleaning up zeromq context"
        @context.terminate
      end
    end

    def shutdown
      Log.info "elector[#{cluster_name}] shutting down"
      @unicast_announcer_thread.stop
      @multicast_listener_thread.stop
      @multicast_announcer_thread.stop
    end

    def unicast_endpoint
      @unicast_endpoint ||= "tcp://#{Pylon::Config[:tcp_address]}:#{Pylon::Config[:tcp_port]}"
    end

    def multicast_endpoint
      @multicast_endpoint ||= "epgm://#{Pylon::Config[:multicast_interface]};#{Pylon::Config[:multicast_address]}:#{Pylon::Config[:multicast_port]}"
    end

    def failure_detectors
      nodes.reject{|n| n == node}.map do |node|
        Thread.new do
          Log.info "failure_detector: starting failure detection against #{node}"
          loop do
            node.send "ping", "timestamp" => Time.now.to_i
          end
        end
      end
    end

    def refresh_failure_detectors
      failure_detectors.each do |thread|
        thread.join
      end
    end

    def add_node node
      nodes << node unless nodes.include? node
      # refresh_failure_detectors
    end

    def remove_node node
      nodes.delete node if nodes.include? node
      # refresh_failure_detectors
    end

    def assert_leadership
      nodes.map do |node|
        Thread.new do
          status = node.send "status"
          Log.info "assert_leadership: status of #{node}: #{status}"
          sync_time = node.send "sync_time"
          Log.info "assert_leadership: sync_time: #{sync_time}"
        end
      end.each do |thread|
        # thread.join
      end if node.master
    end

    def multicast_listener
      Thread.new do
        Log.debug "multicast_listener: zeromq sub socket starting up on #{multicast_endpoint}"
        sub_socket = context.socket ZMQ::SUB
        sub_socket.setsockopt ZMQ::IDENTITY, "node"
        sub_socket.setsockopt ZMQ::SUBSCRIBE, ""
        sub_socket.setsockopt ZMQ::RATE, 1000
        sub_socket.setsockopt ZMQ::MCAST_LOOP, Pylon::Config[:multicast_loopback]
        sub_socket.connect multicast_endpoint
        loop do
          handle_announce sub_socket.recv_string
        end
      end
    end

    def allocate_master
      nodes.sort!.each do |node|
        Log.debug "allocate_master: node: #{node}"
      end
      if node.uuid == nodes.last.uuid
        node.master = true
        Log.info "allocate_master: i am the master: #{node.master})"
      else
        Log.info "allocate_master: someone else is the master, getting ready for work. node.master: #{node.master}"
        node.master = false
      end
    end


    def handle_announce recv_string = ""
      return false if recv_string.empty?
      Log.debug "handle_announce: got string #{recv_string}"
      new_node = JSON.parse(recv_string)
      Log.info "handle_announce: got announce from #{new_node}"

      if nodes.include? new_node
        Log.info "handle_announce: skipping node #{new_node}, already known"
        Log.debug "handle_announce: nodes: #{nodes}"
      else
        Log.info "handle_announce: connecting to #{new_node} on endpoint: #{new_node.unicast_endpoint}"
        connect_node new_node
      end

    end

    def connect_node node
      Log.debug "connect_node: adding node #{node}"
      if nodes.include? node
        Log.info "connect_node: skipping node #{node}, already in local list, sleeping for 60 secs"
        Log.debug "connect_node: nodes: #{nodes}"
        sleep 60
      else
        Log.info "connect_node: connected to node #{node}, adding to local list"
        add_node node
        if nodes.length >= Pylon::Config[:minimum_master_nodes]
          Log.info "connect_node: triggered master election, nodes: #{nodes.length} #{nodes}"
          allocate_master
        end
      end
    end

  end # Elector
end # Pylon
