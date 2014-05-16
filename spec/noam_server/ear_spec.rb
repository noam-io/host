#Copyright (c) 2014, IDEO 

require 'noam_server/ear'

def wire_message(expected_message)
  "%06d" % expected_message.size + expected_message
end

describe NoamServer::Ear do
  let( :host ){ '127.0.0.1' }
  let( :port ){ 5663 }
  let( :ear ){ described_class.new(host, port, nil)}

  class MockConnection

    attr_accessor :sent_messages, :closed, :callback_delegate

    def initialize
      self.sent_messages = []
      self.closed = false
    end

    def send_data(message)
      sent_messages << message
    end

    def close_connection_after_writing
      self.closed = true
    end

    def closed?
      closed
    end

  end

  describe "sending data" do
    before(:each) do
      @connection = MockConnection.new
      EventMachine.stub(:connect).and_yield(@connection)
    end

    context "with the connection created on initialization" do
      it "creates a connection" do
        EventMachine.should_receive(:connect).
                     with(host, port, NoamServer::EarHandler).
                     and_yield(@connection)

        ear.send_data("foobar")
      end

      it "sends data across the connection" do
        ear.send_data("foobar")

        @connection.sent_messages.join.should == "000006foobar"
      end

      it "does not catch any errors raised attempting to connect" do
        EventMachine.should_receive(:connect).and_raise("some error")

        expect {
          ear.send_data("wat")
        }.to raise_error("some error")
      end

      it "sets the callback delegate for the connection" do
        ear.send_data("foobar")

        @connection.callback_delegate.should == ear
      end
    end

    context "with an active connection" do
      it "does not create a new connection" do
        ear.send_data("foo")
        EventMachine.should_not_receive(:connect)
        ear.send_data("bar")

        @connection.sent_messages.join.should include("foo")
        @connection.sent_messages.join.should include("bar")
      end

      it "makes a new connection if we close the connection" do
        ear.send_data("foo")
        ear.terminate
        EventMachine.should_receive(:connect)

        ear.send_data("foobar")
      end
    end

    context "while making a connection" do
      before(:each) do
        ear.terminate
      end

      it "does not make a new connection" do
        EventMachine.stub(:connect)
        ear.send_data("foo")

        EventMachine.should_not_receive(:connect)

        ear.send_data("foobar")

        @connection.sent_messages.should == []
      end

      it "forwards the data when a connection is made" do
        ear.send_data("foobar")

        @connection.sent_messages.join.should == "000006foobar"
      end
    end
  end

  describe "terminate" do
    before(:each) do
      @connection = MockConnection.new
      EventMachine.stub(:connect).and_yield(@connection)
    end

    it "closes the active connection" do
      ear.send_data("foobar")

      ear.terminate

      @connection.should be_closed
    end
  end

end

