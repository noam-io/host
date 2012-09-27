require 'progenitor/orchestra'
require 'progenitor/message_handler'
require 'progenitor/messages'

describe Progenitor::MessageHandler do
  let (:handler) { described_class.new("127.0.0.2") }
  let (:orchestra) { Progenitor::Orchestra.new }

  before do
    Progenitor::Orchestra.stub!(:instance).and_return(orchestra)
  end


  it "should handle a registration message" do
    message = Progenitor::Messages::RegisterMessage.new({})
    message.spalla_id = "1234"
    message.callback_port = 4423
    message.hears = ["e1", "e2"]

    handler.message_received(message)

    orchestra.events["e1"].size.should == 1
    orchestra.events["e1"]["1234"].port.should == 4423
    orchestra.events["e1"]["1234"].host.should == "127.0.0.2"
  end

  it "handles an event message" do
    event_name = 'event name'
    event_value = 'event value'

    connection = mock('Connection')
    player = Progenitor::Player.new( '', '', '', [event_name], [])
    orchestra.register( connection, player )

    message = Progenitor::Messages::EventMessage.new({})
    message.spalla_id = 'player_id'
    message.event_name = event_name
    message.event_value = event_value

    connection.should_receive(:hear).with( 'player_id', event_name, event_value )
    handler.message_received( message )
  end
end
