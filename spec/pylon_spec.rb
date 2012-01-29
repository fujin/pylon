require_relative "./helpers"

describe Pylon do
  it "should have a PYLON_ROOT const defined" do
    Pylon::PYLON_ROOT.wont_be_nil
  end

  it "should have a VERSION const defined" do
    Pylon::VERSION.wont_be_nil
  end
end
