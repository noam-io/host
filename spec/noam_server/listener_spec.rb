require 'noam_server/listener'

class MockEmConnection
  include NoamServer::Listener

  def get_peername; nil; end

  def close_connection_after_writing; nil; end
end

describe NoamServer::Listener do

  it "passes parsed message and connection to handler" do
     connection = MockEmConnection.new
     mock_handler = double("handler")
     NoamServer::MessageHandler.stub(:new).and_return(mock_handler)
     Socket.stub(:unpack_sockaddr_in).and_return([9999, "0.0.0.0"])
     mock_handler.should_receive(:message_received).with(anything, connection)
     connection.post_init
     connection.listener.message_complete
  end

end