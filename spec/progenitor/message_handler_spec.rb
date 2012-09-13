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
    orchestra.events["e1"]["1234"].spalla_id.should == "1234"
    orchestra.events["e1"]["1234"].port.should == 4423
    orchestra.events["e1"]["1234"].host.should == "127.0.0.2"
  end

  it "handles an event message" do
    player = mock("Player", :spalla_id => "444")
    orchestra.register(player, Progenitor::Player.new(["the_event"], []))
    message = Progenitor::Messages::EventMessage.new({})
    message.event_name = "the_event"
    message.event_value = "the_value"

    player.should_receive(:hear).with("the_event", "the_value")

    handler.message_received(message)
  end
end
