require 'noam/messages'
require 'noam_server/udp_broadcaster'

require 'socket'

describe NoamServer::UdpBroadcaster do
  let(:room_name) { "Noam Moderator" }
  let(:http_port) { 8888 }
  let(:broadcast_port) { 24039 }
  let(:expected_beacon_message) { Noam::Messages.build_server_beacon(room_name, http_port) }
  let(:broadcast_ip_1) { '3.4.255.255' }
  let(:broadcast_ip_2) { '101.202.255.255' }
  let(:socket){ double }

  let(:broadcaster) { described_class.new(broadcast_port, room_name, http_port) }

  before :each do
    broad_addr_1 = double("broad_addr_1", :ipv4? => true, :ip_address => broadcast_ip_1)
    ifaddr_1 = double("ifaddr_1", :broadaddr => broad_addr_1)

    broad_addr_2 = double("broad_addr_2", :ipv4? => true, :ip_address => broadcast_ip_2)
    ifaddr_2 = double("ifaddr_2", :broadaddr => broad_addr_2)

    broad_addr_3 = double("broad_addr_3", :ipv4? => false, :ip_address => "6.6.6.6")
    ifaddr_3 = double("ifaddr_3", :broadaddr => broad_addr_3)

    ifaddr_4 = double("ifaddr_4", :broadaddr => nil)

    Socket.stub(:getifaddrs).and_return([ifaddr_1, ifaddr_2, ifaddr_3, ifaddr_4])

    UDPSocket.stub(:new).and_return(socket)
    socket
      .should_receive(:setsockopt)
      .with(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
  end

  it "broadcasts it's IP and port" do
    set_expectation( broadcast_ip_1 )
    set_expectation( broadcast_ip_2 )
    broadcaster.go
  end

  it "broadcasts localhost" do
    set_expectation( "127.0.0.1" )
    broadcaster.go
  end

  it "can broadcast multiple times" do
    set_expectation( broadcast_ip_1 )
    set_expectation( broadcast_ip_1 )
    set_expectation( broadcast_ip_2 )
    set_expectation( broadcast_ip_2 )
    broadcaster.go
    broadcaster.go
  end

  it 'handles network errors' do
    socket
      .should_receive(:send)
      .twice
      .and_raise(Exception)
    broadcaster.go
  end

  it 'broadcasts to all interfaces even if error occurs on one' do
    set_expectation( broadcast_ip_1 )
      .and_raise(Exception)
    set_expectation( broadcast_ip_2 )
    broadcaster.go
  end

  def set_expectation(broadcast_ip)
    socket.should_receive(:send)
      .with(expected_beacon_message, 0, broadcast_ip, broadcast_port)
  end
end

