require 'json'
require 'noam/messages'

describe Noam::Messages do
  it "should parse an event message" do
    message = [ "event", "spalla_id2", "car_speed", 65.32 ].to_json
    parsed = described_class.parse(message)
    parsed.message_type.should == "event"
    parsed.spalla_id.should == "spalla_id2"
    parsed.event_name.should == "car_speed"
    parsed.event_value.should == 65.32
  end

  it "should parse an event message with array values" do
    message = [ "event", "spalla_id2", "car_speed", ["value1", "value2"] ].to_json
    parsed = described_class.parse(message)
    parsed.message_type.should == "event"
    parsed.spalla_id.should == "spalla_id2"
    parsed.event_name.should == "car_speed"
    parsed.event_value.should == ["value1", "value2"]
  end

  it "should parse a registration message" do
    message = [ "register", "spalla_id0", 4423, ["car_speed", "rpm", "volume"], ["headlights"] ].to_json
    parsed = described_class.parse(message)
    parsed.message_type.should == "register"
    parsed.spalla_id.should == "spalla_id0"
    parsed.device_type.should be_nil
    parsed.system_version.should be_nil
    parsed.callback_port.should == 4423
    parsed.hears.should == ["car_speed", "rpm", "volume"]
    parsed.plays.should == ["headlights"]
  end

  it "should parse a registration message with device type and system id" do
    message = [ "register", "spalla_id0", 4423, ["car_speed", "rpm", "volume"], ["headlights"], 'device type', 'system version' ].to_json
    parsed = described_class.parse(message)
    parsed.message_type.should == "register"
    parsed.spalla_id.should == "spalla_id0"
    parsed.device_type.should == "device type"
    parsed.system_version.should == "system version"
    parsed.callback_port.should == 4423
    parsed.hears.should == ["car_speed", "rpm", "volume"]
    parsed.plays.should == ["headlights"]
  end

  it "should build an event message" do
    message = [ "event", "spalla_id2", "car_speed", 65.32 ].to_json
    described_class.build_event("spalla_id2", "car_speed", 65.32).should == message
  end

  it "should build an event with an array value" do
    message = [ "event", "spalla_id2", "car_speed", ["value1", "value2"] ].to_json
    described_class.build_event("spalla_id2", "car_speed", ["value1", "value2"]).should == message
  end

  it "should build a registration message" do
    message = [ "register", "spallaId12", 8921, ["e1", "e2"], ["e3", "e4"] ].to_json
    described_class.build_register("spallaId12", 8921, ["e1", "e2"], ["e3", "e4"]).should == message
  end

  it "should parse what is builds" do
    serial = described_class.build_register("spallaId12", 8921, ["e1", "e2"], ["e3", "e4"])
    parsed = described_class.parse(serial)
    parsed.message_type.should == "register"
    parsed.spalla_id.should == "spallaId12"
    parsed.device_type.should be_nil
    parsed.system_version.should be_nil
    parsed.callback_port.should == 8921
    parsed.hears.should == ["e1", "e2"]
    parsed.plays.should == ["e3", "e4"]
  end
end
