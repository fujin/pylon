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
require_relative "../pylon" # For the PYLON_ROOT const
require_relative "log"
require_relative "exceptions"
require_relative "mixin/convert_to_class_name"

class Pylon
  class Command

    extend Pylon::Mixin::ConvertToClassName

    attr_accessor :options, :config

    def self.options
      @options ||= {}
      @options
    end

    def self.options=(val)
      raise(ArgumentError, "Options must recieve a hash") unless val.kind_of?(Hash)
      @options = val
    end

    def initialize(*args)
      @options = Hash.new
      @config = Hash.new

      klass_options = self.class.options
      klass_options.keys.inject(@options) { |memo,key| memo[key] = klass_options[key].dup; memo }

      @options.each do |config_key, config_opts|
        config[config_key] = config_opts
      end

      super(*args)
    end

    def self.inherited(subclass)
      unless subclass.unnamed?
        commands[subclass.snake_case_name] = subclass
      end
    end

    def self.commands
      @@commands ||= {}
    end

    def self.unnamed?
      name.nil? or name.empty?
    end

    def self.snake_case_name
      convert_to_snake_case(name.split('::').last) unless unnamed?
    end

    def self.common_name
      snake_case_name.split('_').join(' ')
    end

    def self.load_commands
      command_files.each do |file|
        Kernel.load file
      end
      true
    end

    def self.command_files
      @@command_files ||= find_commands.values.flatten.uniq
    end

    def self.find_commands
      files = Dir[File.expand_path('../command/*.rb', __FILE__)]
      command_files = {}
      files.each do |command_file|
        rel_path = command_file[/#{Pylon::PYLON_ROOT}#{Regexp.escape(File::SEPARATOR)}(.*)\.rb/,1]
        command_files[rel_path] = command_file
      end
      command_files
    end

    def self.list_commands
      load_commands
      commands.each do |command|
        Log.info "command loaded: #{command}"
      end
    end

    def self.run(command, options={})
      Log.warn "command: options is not a hash" unless options.is_a? Hash
      load_commands
      command_class = command_class_from(command)
      command_class.options = options.merge!(command_class.options) if options.respond_to? :merge! # just in case 
      instance = command_class.new(command)
      instance.run
    end

    def self.command_class_from(args)
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

    def self.command_not_found!(args)
      Log.debug "command not found: #{args.inspect}"
      raise Pylon::Exceptions::Command::NotFound, args
    end

  end # Command
end # Pylon

