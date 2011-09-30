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
require 'timeout'

class Pylon
  class Exceptions

    class Node
      class PingTimeout < RuntimeError; end
      class BadTimestamp < RuntimeError; end
    end

    class FailureDetector
      class PingTimeout < RuntimeError; end
    end

    class Command
      class NotFound < ArgumentError; end
      class InvalidOptions < ArgumentError; end
    end
    
  end # Exceptions
end # Pylon
