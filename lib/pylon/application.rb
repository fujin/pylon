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

require "mixlib/cli"
require_relative "config"
require_relative "log"
require_relative "daemon"
require_relative "elector"

class Pylon
  class Application
    class << self
      def fatal! message, error_code = -1
        Pylon::Log.fatal message
        Process.exit error_code
      end

    end

    include Mixlib::CLI

    def configure_logging
      Pylon::Log.init(Pylon::Config[:log_location])
      if ( Pylon::Config[:log_location] != STDOUT ) && STDOUT.tty? && (!Pylon::Config[:daemonize])
        stdout_logger = Logger.new(STDOUT)
        STDOUT.sync = true
        stdout_logger.formatter = Pylon::Log.logger.formatter
        Pylon::Log.loggers <<  stdout_logger
      end
      Pylon::Log.level = Pylon::Config[:log_level]
    end

    def run argv=ARGV
      parse_options(argv)
      Pylon::Config.merge!(config)
      configure_logging
      Pylon::Log.info "Pylon #{Pylon::VERSION} warming up"

      Pylon::Daemon.change_privilege
      Pylon::Daemon.daemonize "pylon" if Pylon::Config[:daemonize]

      Pylon::Elector.new
    end

    def initialize
      super
      trap("TERM") do
        Pylon::Application.fatal!("SIGTERM received, stopping", 1)
      end

      trap("INT") do
        Pylon::Application.fatal!("SIGINT received, stopping", 2)
      end

      unless RUBY_PLATFORM =~ /mswin|mingw32|windows/
        trap("QUIT") do
          Pylon::Log.info("SIGQUIT received, call stack:\n  " + caller.join("\n  "))
        end

        trap("HUP") do
          Pylon::Log.info("SIGHUP received, reconfiguring")
          # reconfigure
        end
      end
    end

    option :config_file,
    :short => "-c CONFIG",
    :long  => "--config CONFIG",
    :default => 'config.rb',
    :description => "The configuration file to use"

    option :log_level,
    :short => "-l LEVEL",
    :long  => "--log_level LEVEL",
    :description => "Set the log level (debug, info, warn, error, fatal)",
    :required => true,
    :proc => Proc.new { |l| l.to_sym }

    option :help,
    :short => "-h",
    :long => "--help",
    :description => "Show this message",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0

    option :daemonize,
    :short => "-d",
    :long => "--daemonize",
    :description => "send pylon to the background",
    :proc => lambda { |p| true }

    option :user,
    :short => "-u USER",
    :long => "--user USER",
    :description => "User to set privilege to",
    :proc => nil

    option :group,
    :short => "-g GROUP",
    :long => "--group GROUP",
    :description => "Group to set privilege to",
    :proc => nil

    option :multicast,
    :short => "-M",
    :long => "--multicast",
    :description => "Enable multicast support via encapuslated pragmatic general multicast",
    :proc => lambda { |m| true }

    option :multicast_interface,
    :short => "-i INTERFACE",
    :long => "--multicast-interface INTERFACE",
    :description => "Interface to use to send multicast over"

    option :multicast_address,
    :short => "-a ADDRESS",
    :long => "--multicast-address ADDRESS",
    :description => "Address to use for UDP multicast"

    option :multicast_port,
    :short => "-p PORT",
    :long => "--multicast-port PORT",
    :description => "Port to use for UDP multicast"

    option :multicast_loopback,
    :short => "-L",
    :long => "--multicast-loopback",
    :description => "Enable multicast over loopback interfaces",
    :proc => lambda { |loop| true }

    option :tcp_address,
    :short => "-t TCPADDRESS",
    :long => "--tcp-address TCPADDRESS",
    :description => "Interface to use to bind request socket to"

    option :tcp_port,
    :short => "-P TCPPORT",
    :long => "--tcp-port TCPPORT",
    :description => "Port to bind request socket to"

    option :minimum_master_nodes,
    :short => "-m NODES",
    :long => "--minimum-master-nodes NODES",
    :description => "How many nodes to wait for before starting master election",
    :proc => lambda { |nodes| nodes.to_i }
  end
end
