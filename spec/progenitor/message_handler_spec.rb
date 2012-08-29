require 'progenitor/orchestra'
require 'progenitor/message_handler'
require 'progenitor/messages'

describe Progenitor::MessageHandler do
  let (:orchestra) { Progenitor::Orchestra.new }
  let (:handler) { described_class.new(orchestra) }

  it "should handle a registration message" do
    message = Progenitor::Messages::RegisterMessage.new({})
    message.spalla_id = "1234"
    message.hears = ["e1", "e2"]
    handler.message_received(message)
    orchestra.players["e1"].size.should == 1
  end
end
