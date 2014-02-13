require 'noam_server/grabbed_lemmas'
require 'noam_server/udp_listener'
require 'noam/messages'

class TestUdpConnection
  include NoamServer::UdpHandler
  def get_peername
    "127.0.0.1"
  end
end

describe "UDP Listener" do
  let (:unconnected_lemmas) { NoamServer::UnconnectedLemmas.new }

  before :each do
    Socket.stub(:unpack_sockaddr_in).and_return([1234, "127.0.0.1"])
    NoamServer::UnconnectedLemmas.stub(:instance).and_return(unconnected_lemmas)
  end

  it "should respond to marco with polo" do
    connection = TestUdpConnection.new
    connection.polo = "polo message"
    connection.room_name = "Foo"
    marco = Noam::Messages.build_marco("lemma", "Foo")
    connection.should_receive(:send_data).with("polo message")
    connection.receive_data(marco)
  end

  it "responds with a polo if a grab has been requested" do
    connection = TestUdpConnection.new
    connection.polo = "polo message"
    connection.room_name = "Foo"
    NoamServer::GrabbedLemmas.instance.add("lemma #1")
    marco = Noam::Messages.build_marco("lemma #1", "")
    connection.should_receive(:send_data).with("polo message")
    connection.receive_data(marco)
  end

  it "does NOT respond with a polo when there's a non-blank room, even if a grab has been requested" do
    connection = TestUdpConnection.new
    connection.polo = "polo message"
    connection.room_name = "Foo"
    NoamServer::GrabbedLemmas.instance.add("lemma #1")
    marco = Noam::Messages.build_marco("lemma #1", "Another Room")
    connection.should_not_receive(:send_data)
    connection.receive_data(marco)
  end

  it "should not respond if room name doesn't match" do
    connection = TestUdpConnection.new
    connection.room_name = "Foo"
    marco = Noam::Messages.build_marco("lemma", "Another")
    connection.should_not_receive(:send_data)
    connection.receive_data(marco)
  end

  it "saves the lemma info to if room name doesn't match" do
    connection = TestUdpConnection.new
    connection.room_name = "Foo"
    marco = Noam::Messages.build_marco("lemmaID", "Another")

    NoamServer::UnconnectedLemmas.instance.get("lemmaID").should == nil

    now = Time.now
    Time.stub(:now).and_return(now)

    connection.receive_data(marco)

    NoamServer::UnconnectedLemmas.instance.get("lemmaID").should == {
      :name => "lemmaID",
      :desired_room_name => "Another",
      :port => 1234,
      :ip => "127.0.0.1",
      :device_type => "ruby",
      :system_version => "1.1",
      :last_activity_timestamp => now.getutc
    }
  end

  it "should not respond to a bad message" do
    connection = TestUdpConnection.new
    connection.should_not_receive(:send_data)
    connection.receive_data("crap message")
  end

end
