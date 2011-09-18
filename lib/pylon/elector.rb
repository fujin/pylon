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
      nodes << node unless nodes.include? node
      # fire up a new failure detector
      failure_detectors.each do |thread|
        thread.join
      end
    end

    def ping_node node
      begin
        Pylon::Config[:fd_retries].times do |attempt|
          begin
            Timeout::timeout(Pylon::Config[:fd_timeout]) do
              pong, timestamp = node.send "ping", :attempt => attempt
              if (timestamp - Time.now.to_i) >= 600
                Log.warn "failure_detector: received bad timestamp from #{node}, sending 'exit' message"
                node.send "exit", {"message" => "bad timestamp received after #{Pylon::Config[:fd_retries]}"}
                nodes.delete node
              else
                Log.debug "failure_detector: received good pong with timestamp: #{timestamp}"
                Thread.pass
              end
            end
          rescue Timeout::Error
            Log.warn "failure_detector: #{node} timed out, removing"
            nodes.delete node
          end
        end
      end
    end

    def assert_leadership
      nodes.each do |node|
        Thread.new do
          status = node.send "status"
          Log.info "assert_leadership: status of #{node}: #{status}"
          sync_time = node.send "sync_time"
          Log.info "assert_leadership: sync_time: #{sync_time}"
        end
      end.each do |thread|
        thread.join
      end if master
    end

    def failure_detectors
      nodes.reject{|n| n == node}.map do |node|
        Thread.new do
          Log.info "failure_detector: starting failure detection against #{node}"
          loop do
            assert_leadership
            ping_node node
            allocate_master
          end
        end
      end
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
          uuid = sub_socket.recv_string
          Log.debug "multicast_listener: handling announce from #{uuid}"
          handle_announce sub_socket.recv_string if sub_socket.more_parts?
        end
      end
    end

    def allocate_master
      nodes.sort!.each do |node|
        Log.debug "allocate_master: node: #{node}"
      end
      if node.uuid == nodes.last.uuid
        @master = true
        Log.info "allocate_master: master allocated; sending new_leader"
        nodes.each do |node|
          node.send "new_leader", node
        end
      else
        Log.info "allocate_master: someone else is the master, getting ready for work"
        @master = false
      end
    end

    def handle_announce recv_string
      Log.info "handle_announce: got string #{recv_string}"
      new_node = JSON.parse(recv_string)
      Log.info "handle_anounce: got announce from #{new_node}"
      if master
        Log.info "handle_announce: I am the master: updating #{new_node} of leadership status"
        if node.weight > new_node.weight
          Log.info "handle_announce: I'm bigger than you: sending new_leader to #{new_node}"
          new_node.send "new_leader", node
        else
          Log.info "handle_announce: new leader, sending change_leader to all nodes"
          nodes.each do |n|
            n.send "change_leader", new_node
          end
        end
      elsif nodes.length < Pylon::Config[:minimum_master_nodes]
        if nodes.include? node
          Log.info "handle_announce: skipping node #{node}, already known"
          Log.debug "handle_announce: nodes: #{nodes}"
        else
          Log.info "handle_announce: connecting to #{node} on endpoint: #{node.unicast_endpoint}"
          connect_node node
        end
      end
    end


    def connect_node node
      Log.debug "connect_node: request socket connecting to #{node}"
      new_node = node.send "status"
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

  end # Elector
end # Pylon
