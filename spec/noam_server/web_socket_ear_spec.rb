require 'noam_server/web_socket_ear'
require 'mocks/reactor'

def wire_message(expected_message)
  "%06d" % expected_message.size + expected_message
end

describe NoamServer::WebSocketEar do

  before(:each) do
    @web_socket = double("EM Web Socket", :signature => 1337)
    @ear = NoamServer::WebSocketEar.new(@web_socket)
    @reactor = Mocks::Reactor.new
    EventMachine::Reactor.stub(:instance).and_return(@reactor)
  end

  describe "#send_data" do
    it "sends data with an active connection" do
      @reactor.connect_to(@web_socket)
      message = ""
      @web_socket.stub(:send) do |data|
        message << data
      end

      @ear.send_data('test message')

      message.should == wire_message('test message')
    end

    it "does not send data with no active connection" do
      @web_socket.should_not_receive(:send)
      @ear.send_data('test message')
    end
  end

  describe "#active?" do
    it "is not active if the reactor does not know about the web socket" do
      @ear.should_not be_active
    end

    it "is active if the reactor is keeping track of the web socket" do
      @reactor.connect_to(@web_socket)
      @ear.should be_active
    end
  end

  describe "#terminate" do
    it "closes the web socket with an active connection" do
      @reactor.connect_to(@web_socket)
      @web_socket.should_receive(:close_websocket)
      @ear.terminate
    end

    it "does not close an already closed connection" do
      @web_socket.should_not_receive(:close_websocket)
      @ear.terminate
    end
  end

  it "respondes to new_connection" do
    @ear.should respond_to(:new_connection)
  end

end
