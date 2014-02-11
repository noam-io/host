require 'noam_server/udp_listener'
require 'noam/messages'

class TestUdpConnection
  include NoamServer::UdpHandler
  def get_peername
    "127.0.0.1"
  end
end

describe "UDP Listener" do
  before :each do
    Socket.stub(:unpack_sockaddr_in).and_return(1234, "127.0.0.1")
  end
  it "should respond to marco with polo" do
    connection = TestUdpConnection.new
    connection.polo = "polo message"
    connection.room_name = "Foo"
    marco = Noam::Messages.build_marco("lemma", "Foo", 1234 )
    connection.should_receive(:send_data).with("polo message")
    connection.receive_data(marco)
  end

  it "should not respond if room name doesn't match" do
    connection = TestUdpConnection.new
    connection.room_name = "Foo"
    marco = Noam::Messages.build_marco("lemma", "Another", 1234 )
    connection.should_not_receive(:send_data)
    connection.receive_data(marco)
  end

  it "should not respond to a bad message" do
    connection = TestUdpConnection.new
    connection.should_not_receive(:send_data)
    connection.receive_data("crap message")
  end

end
