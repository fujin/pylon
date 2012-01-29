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
require_relative "../pylon" # For the PYLON_ROOT const
require_relative "log"
require_relative "exceptions"
require_relative "mixin/convert_to_class_name"

class Pylon
  class Command

    extend Pylon::Mixin::ConvertToClassName

    attr_accessor :options, :config

    def initialize
      @options = Hash.new
      @config = Hash.new

      klass_options = self.class.options
      klass_options.keys.inject(@options) { |memo,key| memo[key] = klass_options[key].freeze; memo }

      @options.each do |config_key, config_opts|
        config[config_key] = config_opts
      end
    end

    class << self
      def options
        @options ||= {}
        @options
      end

      def options=(val)
        raise(ArgumentError, "Options must recieve a hash") unless val.kind_of?(Hash)
        @options = val
      end


      def inherited(subclass)
        unless subclass.unnamed?
          commands[subclass.snake_case_name] = subclass
        end
      end

      def commands
        @@commands ||= {}
      end

      def unnamed?
        name.nil? or name.empty?
      end

      def snake_case_name
        convert_to_snake_case(name.split('::').last) unless unnamed?
      end

      def common_name
        snake_case_name.split('_').join(' ')
      end

      def load_commands
        command_files.each do |file|
          Kernel.load file
        end
        true
      end

      def command_files
        @@command_files ||= find_commands.values.flatten.uniq
      end

      def find_commands
        files = Dir[File.expand_path('../command/*.rb', __FILE__)]
        command_files = {}
        files.each do |command_file|
          rel_path = command_file[/#{Pylon::PYLON_ROOT}#{Regexp.escape(File::SEPARATOR)}(.*)\.rb/,1]
          command_files[rel_path] = command_file
        end
        command_files
      end

      def list_commands
        load_commands
        commands.each do |command|
          Log.info "command loaded: #{command}"
        end
      end

      def run(command, options={})
        Log.warn "command: options is not a hash" unless options.is_a? Hash
        load_commands
        command_class = command_class_from(command)
        Log.debug "command: #{command_class}"
        command_class.options = options.merge!(command_class.options) if options.respond_to? :merge! # just in case
        Log.debug "command: options: #{command_class.options}"
        instance = command_class.new
        instance.run
      end

      def command_class_from(args)
        args = [args].flatten
        command_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ }
        command_class = nil
        while ( !command_class ) && ( !command_words.empty? )
          snake_case_class_name = command_words.join("_")
          unless command_class = commands[snake_case_class_name]
            command_words.pop
          end
        end
        command_class ||= commands[args.first.gsub('-', '_')]
        command_class || command_not_found!(args)
      end

      def command_not_found!(args)
        Log.debug "command not found: #{args.inspect}"
        raise Pylon::Exceptions::Command::NotFound, args
      end

    end # self
  end # Command
end # Pylon
