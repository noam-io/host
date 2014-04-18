require 'noam_server/noam_server'
require 'noam_server/orchestra'
require 'noam_server/message_handler'
require 'noam/messages'

describe NoamServer::MessageHandler do
  let (:handler) { described_class.new("127.0.0.2") }
  let (:orchestra) { NoamServer::Orchestra.new }

  before do
    NoamServer::NoamServer.stub(:room_name).and_return("RoomName")
    NoamServer::Orchestra.stub(:instance).and_return(orchestra)
  end

  it "should handle a registration message" do
    message = Noam::Messages::RegisterMessage.new({})
    message.spalla_id = "1234"
    message.device_type = "device type"
    message.system_version = "system version"
    message.callback_port = 4423
    message.hears = ["e1", "e2"]
    message.options = {}

    connection = double("TCP Connection")

    handler.message_received(message, connection)

    orchestra.events["e1"].size.should == 1
    orchestra.events["e1"]["1234"].port.should == 4423
    orchestra.events["e1"]["1234"].host.should == "127.0.0.2"
    orchestra.events["e1"]["1234"].ear.incoming_connection.should == connection

    orchestra.players["1234"].spalla_id.should == '1234'
    orchestra.players["1234"].device_type.should == 'device type'
    orchestra.players["1234"].system_version.should == 'system version'
  end

  it "handles an event message" do
    event_name = 'event name'
    event_value = 'event value'

    connection = double('Connection')
    player_id = 'player_id'
    player = NoamServer::Player.new(player_id, '', '', [event_name], [], 0, 0, "RoomName")
    orchestra.register(connection, player)

    message = Noam::Messages::EventMessage.new({})
    message.spalla_id = player_id
    message.event_name = event_name
    message.event_value = event_value

    connection.should_receive(:send_event).with( 'player_id', event_name, event_value )
    handler.message_received( message, connection )
  end
end
