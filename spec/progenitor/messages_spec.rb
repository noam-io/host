require 'json'
require 'progenitor/messages'

describe Progenitor::Messages do
  it "should parse an event message" do
    message = [ "event", "spalla_id2", "car_speed", 65.32 ].to_json
    parsed = described_class.parse(message)
    parsed.message_type.should == "event"
    parsed.spalla_id.should == "spalla_id2"
    parsed.event_name.should == "car_speed"
    parsed.event_value.should == 65.32
  end

  it "should parse a registration message" do
    message = [ "register", "spalla_id0", 4423, ["car_speed", "rpm", "volume"], ["headlights"] ].to_json
    parsed = described_class.parse(message)
    parsed.message_type.should == "register"
    parsed.spalla_id.should == "spalla_id0"
    parsed.callback_port.should == 4423
    parsed.hears.should == ["car_speed", "rpm", "volume"]
    parsed.plays.should == ["headlights"]
  end
end
