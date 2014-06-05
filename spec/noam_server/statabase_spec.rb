# Copyright (c) 2014, IDEO

require 'noam_server/statabase'

describe NoamServer::Statabase do
  let(:statabase) { NoamServer::Statabase.instance }

  it "#instance returns the same instance" do
    described_class.instance.should === described_class.instance
  end

  it "#set stores the value associated with the given name" do
    statabase.set("example", 123)
    statabase.get("example").should == 123
  end

  it "#get retrieves the value 0 when no value is associated with the given name" do
    statabase.get("invalid").should == 0
  end

  it "#set updates the value associated with the given name" do
    statabase.set("example", 123)
    statabase.set("example", 456)
    statabase.get("example").should == 456
  end

  it "#set associates a timestamp with the given name" do
    before_time = DateTime.now
    statabase.set("sample", 123)
    statabase.timestamp("sample").should >= before_time
    statabase.timestamp("sample").should <= DateTime.now
  end

  it "#set updates the timestamp associated with the given name" do
    statabase.set("sample", "before_value") and sleep(0.0001)
    before_time = DateTime.now
    statabase.set("sample", "after_value")
    statabase.timestamp("sample").should >= before_time
  end
end
