require_relative "./spec_helper"

describe Pylon do
  it "should have a PYLON_ROOT const defined" do
    Pylon::PYLON_ROOT.should_not be_nil
  end

  it "should have a VERSION const defined" do
    Pylon::VERSION.should_not be_nil
  end
end

describe Kernel do
  it "should respond to require_relative (even on 1.8)" do
    Kernel.should respond_to :require_relative
  end
end

