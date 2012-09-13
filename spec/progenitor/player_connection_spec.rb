require 'eventmachine'
require 'progenitor/player_connection'

def wire_message(expected_message)
  "%06d" % expected_message.size + expected_message
end

describe Progenitor::PlayerConnection do
  it "should hear" do
    module TestConnection
      def receive_data(data)
        data.should == wire_message(Progenitor::Messages.build_event("spalla123", "event_name", "event_value"))
        EM::stop_event_loop
      end
    end
    EM::run do
      server = EventMachine::start_server("127.0.0.1", 5652, TestConnection)
      player = described_class.new("spalla123", "127.0.0.1", 5652)
      player.hear("event_name", "event_value")
    end
  end

  it "should hear twice" do
    module TestConnection
      def receive_data(data)
        data.should == wire_message(Progenitor::Messages.build_event("spalla123", "event_name", "event_value")) +
          wire_message(Progenitor::Messages.build_event("spalla123", "event2_name", "event3_value"))
        EM::stop_event_loop
      end
    end
    EM::run do
      server = EventMachine::start_server("127.0.0.1", 5652, TestConnection)
      player = described_class.new("spalla123", "127.0.0.1", 5652)
      player.hear("event_name", "event_value")
      player.hear("event2_name", "event3_value")
    end
  end
end
