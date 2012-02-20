# -*- coding: utf-8 -*-
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

require_relative "../log"
require_relative "../paxos"

class Pylon
  module Paxos
    class ReplicaClient
      def cid
        UUIDTools::UUID.timestamp_create
      end

      def nodes
        ::DCell::Node.all.inject([]) do |nodes, node|
          nodes << node if node.actors.include? :paxos_replica
        end
      end

      def run
        loop do
          nodes.each do |node|
            response = lambda do |state|
              state[:times_updated] ||= 0
              state.merge(:last_updated => Time.now.to_i,
                          :times_updated => state[:times_updated] + 1)

            end

            command = Pylon::Paxos::Command.new(self, cid, response)

            node[:paxos_replica].request(command)
          end

          sleep 420
        end
      end

    end

    def initialize
      Pylon::Log.info "#{self}#initialize: starting up"
      run!
    end
  end
end
