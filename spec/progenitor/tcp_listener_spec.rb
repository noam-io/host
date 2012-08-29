require 'progenitor/tcp_listener'

describe Progenitor::TcpListener do
  context "with listener" do
    let (:listener) { described_class.new }

    it "should read length" do
      listener.receive_data("000005")
      listener.message_length.should == 5
    end

    it "should read length in two pieces" do
      listener.receive_data("001")
      listener.message_length.should == nil

      listener.receive_data("008")
      listener.message_length.should == 1008
    end

    it "should not read length passed 6 characters" do
      listener.receive_data("0000010ba")
      listener.message_payload.size.should == 1
    end

    it "should read message that follows" do
      listener.receive_data("000009abcdefghi")
      listener.message_payload.should == "abcdefghi"
    end

    it "should read multiple messages" do
      listener.receive_data("000001a")
      listener.message_payload.should == "a"
      listener.receive_data("000001b")
      listener.message_payload.should == "b"
    end

    it "should receive zero length message" do
      listener.receive_data("000000")
      listener.message_payload.should == ""
      listener.receive_data("000001b")
      listener.message_payload.should == "b"
    end
  end

  it "should run callback when message received" do
    listener = described_class.new do | message |
      @message = message
    end
    listener.receive_data("000002ab")
    @message.should == "ab"
  end

  it "should run callback for multiple messages" do
    @messages = []
    listener = described_class.new do | message |
      @messages << message
    end
    listener.receive_data("000002ab")
    listener.receive_data("000002cd")
    @messages.should == ["ab", "cd"]
  end
end
