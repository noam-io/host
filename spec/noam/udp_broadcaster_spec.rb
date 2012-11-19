require 'noam/udp_broadcaster'

describe Progenitor::UdpBroadcaster do
  let(:broadcast_port) { 24039 }
  let(:listen_port) { 24039 }
  let(:broadcast_ip_1) { '3.4.255.255' }
  let(:broadcast_ip_2) { '101.202.255.255' }
  let(:socket){ mock }

  let(:broadcaster) { described_class.new( broadcast_port, listen_port ) }

  before :each do
    ifconfig_grep_result = [
      "1.2.3.4 broadcast #{broadcast_ip_1}",
      "100.101.200.202 broadcast #{broadcast_ip_2}"
    ].join($/)
    Progenitor::UdpBroadcaster.any_instance
      .should_receive(:`)
      .with( 'ifconfig | grep broadcast' )
      .at_least( :once )
      .and_return( ifconfig_grep_result )

    UDPSocket.stub( :new ).and_return( socket )
    socket
      .should_receive( :setsockopt )
      .with( Socket::SOL_SOCKET, Socket::SO_BROADCAST, true )
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

  def set_expectation( broadcast_ip )
    socket.should_receive(:send)
      .with("[Maestro@#{broadcast_port}]", 0, broadcast_ip, listen_port)
  end
end

