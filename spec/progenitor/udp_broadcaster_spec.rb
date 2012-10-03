require 'progenitor/udp_broadcaster'

describe Progenitor::UdpBroadcaster do
  let(:port) { 24039 }
  let(:ip_1_host) { '3.4.5.6' }
  let(:ip_1_broadcast) { '3.4.255.255' }
  let(:ip_2_host) { '101.202.303.404' }
  let(:ip_2_broadcast) { '101.202.255.255' }

  let(:broadcaster) { described_class.new( port ) }

  before :each do
    ips_and_broadcast_ips = [
      "#{ip_1_host} broadcast #{ip_1_broadcast}",
      "#{ip_2_host} broadcast #{ip_2_broadcast}"
    ].join($/)
    Progenitor::UdpBroadcaster.any_instance.stub(:`)
      .and_return( ips_and_broadcast_ips )
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
    UDPSocket.any_instance
      .should_receive(:send)
      .twice
      .and_raise(Exception)
    broadcaster.go
  end

  it 'broadcasts to all interfaces even if error occurs on one' do
    set_expectation( ip_1_host, ip_1_broadcast )
      .and_raise(Exception)
    set_expectation( ip_2_host, ip_2_broadcast )
    broadcaster.go
  end

  def set_expectation( host_ip, broadcast_ip )
    UDPSocket
      .any_instance
      .should_receive(:send)
      .with("[Maestro@1.2.3.4:#{port}]", 0, broadcast_ip, port)
  end
end

