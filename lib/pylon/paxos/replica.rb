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
    class Replica
      # Let's create a memory-only, hash based Replica state machine
      # ..it has a sequence of slots that should be filled with
      # commands

      # Invariants:
      #
      # R1: There are no two different commands decided
      # for the same slot: ∀s, ρ1 , ρ2 , p1 , p2 : s, p1 ∈
      # ρ1 .decisions ∧ s, p2 ∈ ρ2 .decisions ⇒ p1 = p2
      #
      # R2: All commands up to slot num are in the set of
      # decisions: ∀ρ, s : 1 ≤ s < ρ.slot num ⇒
      # (∃p : s, p ∈ ρ.decisions)
      #
      # R3: For all replicas ρ, ρ.state is the result of applying
      # the operations in s, ps ∈ ρ.decisions for all s
      # such that 1 ≤ s < slot num, in order of slot
      # number, to initial state.
      #
      # R4: For each ρ, the variable ρ.slot num cannot de-
      # crease over time.
      #

      include Celluloid

      @lock = Mutex.new

      attr_reader( :state,
                   :slot_num,
                   :proposals,
                   :decisions )

      def leaders
        Timeout::timeout(10) do
          ::DCell::Node.all.inject([]) do |nodes, node|
            nodes << node if node.actors.include? :paxos_leader
          end
        end
      end

      def initialize
        Pylon::Log.info "#{self}#initialize: starting up"

        # Initial state
        @state = {}

        # This is like the state version
        @slot_num = 1
        # proposals the replica has made in the past, slot number => command
        @proposals = {}
        # slots we have decided, also slot number => command
        @decisions = {}

        run!
      end

      def next_slot_num
        @state.length + 1
      end

      def propose( proposal )
        seq = next_slot_num
        unless decisions.has_value? proposal

          proposals[seq] = proposal

          leaders.each do |leader|
            leader[:paxos_leader].propose(seq, proposal)
          end

        end
      end

      # This is going to be a command, [k,cid,op]
      def request( proposal )
        propose proposal
      end

      # Make a decision about a proposal
      def decision sequence, proposal
        # Save this decision as seen
        decisions[sequence] = proposal

        # Wait for a decision to be made for the current slot_num,
        # i.e., the state is up to date
        while decision = decisions[slot_num] do
          # If we've already proposed a different decision, re-propose
          # our decision while increasing the slot
          if proposals.has_key? slot_num and proposal[slot_num] != decision
            propose(decision)
          end
          # Run the proposal
          perform(proposal)
        end
      end

      # Perform a command
      def perform command
        if decisions.detect do |slot,decision|
            # If the stored decision has a lower slot than our current
            # slot_num and is the same as the command being requested
            slot < slot_num and command == decision
          end
          # We've already made our decision for this command
          slot_num =+ 1
        else
          # Is it necessary to marshal dump the state for a deep copy
          # here? state has to be updated exclusively
          #
          # new_state = command[:op].call(state)
          new_state = command[:op].call(Marshal.load(Marshal.dump(state)))
          exclusive do
            state = new_state
            slot_num =+ 1
          end
          # We've calcualted our result, send it to the client
          command[:k][:paxos_client].response( command[:cid],
                                               new_state )
        end

      end

    end
  end
end
