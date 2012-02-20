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

require_relative "../paxos"

class Pylon
  module Paxos
    class Replica
      @lock = Mutex.new

      attr_reader( :state,
                   :proposals,
                   :slot_num,
                   :decisions )

      def initialize(leaders, initial_state)
        @state = initial_state
        @slot_num = 1
        @proposals = 0
        @decisions = 0
      end

      def propose(p)

      end

      def perform(*args)
      end

    end
  end
end
