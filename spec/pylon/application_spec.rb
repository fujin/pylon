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
    Pylon::Log.logger = Logger.new(StringIO.new)
    @app = Pylon::Application.new
    Dir.stub!(:chdir).and_return(0)
    @app.stub!(:reconfigure)
  end

  describe "run" do
    it "needs tests"
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

  describe "setup_application" do
    before do
      @app = Pylon::Application.new
    end

    it "should raise an error" do
      lambda { @app.setup_application }.should raise_error(Pylon::Exceptions::Application)
    end
  end

  describe "run_application" do
    before do
      @app = Pylon::Application.new
    end

    it "should raise an error" do
      lambda { @app.run_application }.should raise_error(Pylon::Exceptions::Application)
    end
  end
end
