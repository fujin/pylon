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
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../spec_helper"

describe Pylon::Application do
  before do
    @original_config = Pylon::Config.configuration
    Pylon::Log.logger = Logger.new(StringIO.new)
    @app = Pylon::Application.new
    Dir.stub!(:chdir).and_return(0)
    @app.stub!(:reconfigure)
  end

  after do
    Pylon::Config.configuration.replace(@original_config)
  end

  describe "run" do
    before do
      @app.stub!(:parse_options).and_return(true)
      Pylon::Config.stub!(:merge!).and_return(true)
      @app.stub!(:configure_logging).and_return(true)
      Pylon::DCell.stub!(:new).and_return(true)
    end

    it "should parse options" do
      @app.should_receive(:parse_options).and_return(true)
      @app.run
    end

    it "should merge configuration options from the cli" do
      Pylon::Config.should_receive(:merge!).once.and_return(true)
      @app.run
    end

    it "should call configure logging" do
      @app.should_receive(:configure_logging).and_return(true)
      @app.run
    end

    it "should call change_privilege" do
      Pylon::Daemon.should_receive(:change_privilege).and_return(true)
      @app.run
    end

    it "should not daemonize" do
      Pylon::Config[:daemonize] = false
      Pylon::Daemon.should_not_receive(:daemonize).with("pylon")
      @app.run
    end

    describe "if daemonize is enabled" do
      before do
        Pylon::Config[:daemonize] = true
      end

      it "should daemonize" do
        Pylon::Daemon.should_receive(:daemonize).with("pylon").and_return(true)
        @app.run
      end
    end
  end

  describe "configure_logging" do
    before do
      @app = Pylon::Application.new
      Pylon::Log.stub!(:init)
      Pylon::Log.stub!(:level=)
    end

    it "should initialise the pylon logger" do
      Pylon::Log.should_receive(:init).with(Pylon::Config[:log_location]).and_return(true)
      @app.configure_logging
    end

    it "should initialise the pylon logger level" do
      Pylon::Log.should_receive(:level=).with(Pylon::Config[:log_level]).and_return(true)
      @app.configure_logging
    end

  end

  describe "class method: fatal!" do
    before do
      STDERR.stub!(:puts).with("FATAL: blah").and_return(true)
      Pylon::Log.stub!(:fatal).with("blah").and_return(true)
      Process.stub!(:exit).and_return(true)
    end

    it "should log an error message to the logger" do
      Pylon::Log.should_receive(:fatal).with("blah").and_return(true)
      Pylon::Application.fatal! "blah"
    end

    describe "when an exit code is supplied" do
      it "should exit with the given exit code" do
        Process.should_receive(:exit).with(-100).and_return(true)
        Pylon::Application.fatal! "blah", -100
      end
    end

    describe "when an exit code is not supplied" do
      it "should exit with the default exit code" do
        Process.should_receive(:exit).with(-1).and_return(true)
        Pylon::Application.fatal! "blah"
      end
    end

  end
end
