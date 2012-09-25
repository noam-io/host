require 'progenitor/udp_broadcaster'

describe Progenitor::UdpBroadcaster do
  let(:port) { 24039 }
  let(:ip_1_host) { '3.4.5.6' }
  let(:ip_1_broadcast) { '3.4.5.255' }
  let(:ip_2_host) { '101.202.303.404' }
  let(:ip_2_broadcast) { '101.202.303.255' }
  let(:interface_1) { mock( ipv4_private?: true, ip_address: ip_1_host )}
  let(:interface_2) { mock( ipv4_private?: true, ip_address: ip_2_host )}

  let(:broadcaster) { described_class.new( port ) }

  before :each do
    network_interfaces = [ interface_1, interface_2 ]
    Socket.stub(:ip_address_list).and_return( network_interfaces )
  end

  it "broadcasts it's IP and port" do
    set_expectation( ip_1_host, ip_1_broadcast )
    set_expectation( ip_2_host, ip_2_broadcast )
    broadcaster.go
  end

  it "can broadcast multiple times" do
    set_expectation( ip_1_host, ip_1_broadcast )
    set_expectation( ip_1_host, ip_1_broadcast )
    set_expectation( ip_2_host, ip_2_broadcast )
    set_expectation( ip_2_host, ip_2_broadcast )
    broadcaster.go
    broadcaster.go
  end

  it 'handles network errors' do
    UDPSocket.any_instance.should_receive(:send).and_raise(Exception)
    broadcaster.go
  end

  def set_expectation( host_ip, broadcast_ip )
    UDPSocket
      .any_instance
      .should_receive(:send)
      .with("[Maestro@#{host_ip}:#{port}]", 0, broadcast_ip, port)
  end
end

