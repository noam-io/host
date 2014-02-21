require 'noam_server/orchestra'
require 'noam_server/web_socket_message_handler'
require 'noam/messages'

describe NoamServer::WebSocketMessageHandler do
  let (:ws) { double("ws") }
  let (:handler) { described_class.new(ws) }
  let (:orchestra) { NoamServer::Orchestra.new }

  before do
    NoamServer::Orchestra.stub(:instance).and_return(orchestra)
  end


  it "should handle a registration message" do
    message = Noam::Messages::RegisterMessage.new({})
    message.spalla_id = "1234"
    message.device_type = "device type"
    message.system_version = "system version"
    message.callback_port = 0
    message.hears = ["e1", "e2"]

    handler.message_received(message)

    orchestra.events["e1"].size.should == 1
    orchestra.events["e1"]["1234"].ear.should be_a(NoamServer::WebSocketEar)

    orchestra.players["1234"].spalla_id.should == '1234'
    orchestra.players["1234"].device_type.should == 'device type'
    orchestra.players["1234"].system_version.should == 'system version'
  end

  it "handles an event message" do
    event_name = 'event name'
    event_value = 'event value'

    connection = double('Connection')
    player = NoamServer::Player.new( 'player_id', '', '', [event_name], [], 0, 0)
    orchestra.register( connection, player )

    message = Noam::Messages::EventMessage.new({})
    message.spalla_id = 'player_id'
    message.event_name = event_name
    message.event_value = event_value

    connection.should_receive(:hear).with( 'player_id', event_name, event_value )
    handler.message_received( message )
  end
end
