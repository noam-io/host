require 'progenitor/orchestra'
require 'progenitor/message_handler'
require 'orchestra/messages'

describe Progenitor::MessageHandler do
  let (:handler) { described_class.new("127.0.0.2") }
  let (:orchestra) { Progenitor::Orchestra.new }

  before do
    Progenitor::Orchestra.stub!(:instance).and_return(orchestra)
  end


  it "should handle a registration message" do
    message = ::Orchestra::Messages::RegisterMessage.new({})
    message.spalla_id = "1234"
    message.device_type = "device type"
    message.system_version = "system version"
    message.callback_port = 4423
    message.hears = ["e1", "e2"]

    handler.message_received(message)

    orchestra.events["e1"].size.should == 1

    orchestra.players["1234"].spalla_id.should == '1234'
    orchestra.players["1234"].device_type.should == 'device type'
    orchestra.players["1234"].system_version.should == 'system version'
  end

  it "handles an event message" do
    event_name = 'event name'
    event_value = 'event value'

    connection = mock('Connection')
    player = Progenitor::Player.new( '', '', '', [event_name], [])
    orchestra.register( connection, player )

    message = Orchestra::Messages::EventMessage.new({})
    message.spalla_id = 'player_id'
    message.event_name = event_name
    message.event_value = event_value

    connection.should_receive(:hear).with( 'player_id', event_name, event_value )
    handler.message_received( message )
  end
end
