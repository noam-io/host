require 'progenitor/udp_broadcaster'

describe Progenitor::UdpBroadcaster do
  it "broadcasts it's IP and port" do
    port = 24039
    data = nil

    readThread = Thread.new do
      address = '0.0.0.0'
      BasicSocket.do_not_reverse_lookup = true

      socket = UDPSocket.new
      socket.bind(address, port)
      data, addr = socket.recvfrom(1024)
      socket.close
    end

    broadcaster = described_class.new(port)
    broadcaster.go

    readThread.join

    expected_message = "[Maestro@#{local_ip}:#{port}]"
    data.should == expected_message
  end

  def local_ip
    ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
    ip.ip_address if ip
  end
end

