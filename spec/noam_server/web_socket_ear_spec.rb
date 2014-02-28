require 'noam_server/web_socket_ear'

def wire_message(expected_message)
  "%06d" % expected_message.size + expected_message
end

describe NoamServer::WebSocketEar do
  let( :ws ) { double("web socket") }
  let( :ear ){ described_class.new( ws ) }

  it "should hear" do
    message = ""
    ws.stub(:send) do | data |
      message << data
    end

    ear.send_data('test message')

    message.should == wire_message('test message')
  end

  it "should terminate" do
    ws.should_receive(:close_websocket)
    ear.terminate
  end
end

