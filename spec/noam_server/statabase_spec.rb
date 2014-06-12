# Copyright (c) 2014, IDEO

require 'noam_server/statabase'

describe NoamServer::Statabase do
  let(:statabase) { NoamServer::Statabase.instance }

  it "#instance returns the same instance" do
    described_class.instance.should === described_class.instance
  end

  it "#set stores the value associated with the given name" do
    statabase.set("example_evt", "player1", 123)
    statabase.get("example_evt", "player1").should == 123
  end

	it "#set stores the values of events of 2 players" do
		statabase.set("example_evt", "player1", 123)
		statabase.set("example_evt", "player2", 456)
		statabase.get("example_evt", "player1").should == 123
		statabase.get("example_evt", "player2").should == 456
	end

	it "#get retrieves the value 0 when no value is associated with the given name" do
    statabase.get("invalid", "invalid").should == 0
  end

  it "#set updates the value associated with the given name" do
    statabase.set("example_evt", "player1", 123)
    statabase.set("example", "player1",456)
    statabase.get("example", "player1").should == 456
  end

  it "#set associates a timestamp with the given name" do
    before_time = DateTime.now
    statabase.set("sample_evt", "player1", 123)
    statabase.timestamp("sample_evt", "player1").should >= before_time
    statabase.timestamp("sample_evt", "player1").should <= DateTime.now
  end

  it "#set updates the timestamp associated with the given name" do
    statabase.set("sample_evt", "player_1", "before_value") and sleep(0.0001)
    before_time = DateTime.now
    statabase.set("sample", "player_1", "after_value")
    statabase.timestamp("sample", "player_1",).should >= before_time
	end

	it "should throw an exception if player is not specified when setting" do
		expect {statabase.set("example_evt", 123)}.to raise_error(ArgumentError)
	end
end
