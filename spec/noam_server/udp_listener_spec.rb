#Copyright (c) 2014, IDEO 

require 'noam_server/grabbed_lemmas'
require 'noam_server/located_servers'
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
  let (:located_servers) { NoamServer::LocatedServers.new }

  before :each do
    NoamServer::NoamServer.stub(:on?).and_return(true)
    Socket.stub(:unpack_sockaddr_in).and_return([1234, "127.0.0.1"])
    NoamServer::UnconnectedLemmas.stub(:instance).and_return(unconnected_lemmas)
    NoamServer::LocatedServers.stub(:instance).and_return(located_servers)
  end

  it "should respond to marco with polo" do
    connection = TestUdpConnection.new
    NoamServer::NoamServer.room_name = "Foo"
    marco = Noam::Messages.build_marco("lemma", "Foo")
    connection.should_receive(:send_data).with(connection.make_polo)
    connection.receive_data(marco)
  end

  it "builds the polo message properly" do
    connection = TestUdpConnection.new
    connection.tcp_listen_port = 9876
    NoamServer::NoamServer.room_name = "Foo"
    connection.make_polo.should == ["polo", "Foo", 9876].to_json
  end

  it "responds with a polo if a grab has been requested" do
    connection = TestUdpConnection.new
    NoamServer::NoamServer.room_name = "Foo"
    NoamServer::GrabbedLemmas.instance.add({:name => "lemma #1"})
    marco = Noam::Messages.build_marco("lemma #1", "")
    connection.should_receive(:send_data).with(connection.make_polo)
    connection.receive_data(marco)
  end

  it "does NOT respond with a polo when there's a non-blank room, even if a grab has been requested" do
    connection = TestUdpConnection.new
    NoamServer::NoamServer.room_name = "Foo"
    NoamServer::GrabbedLemmas.instance.add({:name => "lemma #1"})
    marco = Noam::Messages.build_marco("lemma #1", "Another Room")
    connection.should_not_receive(:send_data)
    connection.receive_data(marco)
  end

  it "should not respond if room name doesn't match" do
    connection = TestUdpConnection.new
    NoamServer::NoamServer.room_name = "Foo"
    marco = Noam::Messages.build_marco("lemma", "Another")
    connection.should_not_receive(:send_data)
    connection.receive_data(marco)
  end

  it "saves the lemma info to if room name doesn't match" do
    connection = TestUdpConnection.new
    NoamServer::NoamServer.room_name = "Foo"
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

  it "saves located server information" do
    connection = TestUdpConnection.new
    NoamServer::NoamServer.room_name = "Foo"
    beacon = Noam::Messages.build_server_beacon("Another Room ID", 9876)

    NoamServer::LocatedServers.instance.get("Another Room ID").should == nil

    now = Time.now
    Time.stub(:now).and_return(now)

    connection.receive_data(beacon)

    NoamServer::LocatedServers.instance.get("Another Room ID").should == {
      :name => "Another Room ID",
      :http_port => 9876,
      :beacon_port => 1234,
      :ip => "127.0.0.1",
      :last_activity_timestamp => now.getutc
    }
  end

  it "stops listening when the server is off" do
    connection = TestUdpConnection.new
    NoamServer::NoamServer.room_name = "Foo"
    beacon = Noam::Messages.build_server_beacon("Another Room ID", 9876)
    NoamServer::NoamServer.stub(:on?).and_return(false)
    Noam::Messages.should_not_receive(:parse)

    connection.receive_data(beacon)
  end

end
