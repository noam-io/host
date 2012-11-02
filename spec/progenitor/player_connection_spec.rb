require 'eventmachine'
require 'progenitor/player_connection'

def wire_message(expected_message)
  "%06d" % expected_message.size + expected_message
end

describe Progenitor::PlayerConnection do

  ID_OF_PLAYER = "id of player"
  NAME_1 = "name 1"
  NAME_2 = "name 2"
  VALUE_1 = "value 1"
  VALUE_2 = "value 2"

  it "should hear" do

    module TestConnection
      def receive_data(data)
        data.should == wire_message(Orchestra::Messages.build_event( ID_OF_PLAYER, NAME_1, VALUE_1 ))
        EM::stop_event_loop
      end
    end
    EM::run do
      server = EventMachine::start_server("127.0.0.1", 5652, TestConnection)
      player = described_class.new( mock("player", :host => "127.0.0.1", :port => 5652) )
      player.hear( ID_OF_PLAYER, NAME_1, VALUE_1 )
    end
  end

  it "should hear twice" do
    module TestConnection
      def receive_data(data)
        message_1 = wire_message(Orchestra::Messages.build_event( ID_OF_PLAYER, NAME_1, VALUE_1 ))
        message_2 = wire_message(Orchestra::Messages.build_event( ID_OF_PLAYER, NAME_2, VALUE_2 ))

        data.should == message_1 + message_2
        EM::stop_event_loop
      end
    end
    EM::run do
      server = EventMachine::start_server("127.0.0.1", 5652, TestConnection)
      player = described_class.new( mock("player", :host => "127.0.0.1", :port => 5652) )
      player.hear( ID_OF_PLAYER, NAME_1, VALUE_1 )
      player.hear( ID_OF_PLAYER, NAME_2, VALUE_2 )
    end
  end
end

