require 'progenitor/udp_broadcaster'

describe Progenitor::UdpBroadcaster do
  let(:port) { 24039 }
  let(:expected_message) { "[Maestro@#{local_ip}:#{port}]" }
  let(:broadcaster) { described_class.new(port) }
  let(:data) {[]}
  let(:address) { '0.0.0.0' }
  let(:socket) { UDPSocket.new }

  before :all do
    BasicSocket.do_not_reverse_lookup = true
  end


  before :each do
    socket.bind(address, port)
  end

  after :each do
    socket.close
  end

  it "broadcasts it's IP and port" do
    broadcast_and_read

    data.count.should == 1
    data[0].should == expected_message
  end

  it "can broadcast multiple times" do
    broadcast_and_read
    broadcast_and_read

    data.count.should == 2
    data[0].should == expected_message
    data[1].should == expected_message
  end

  it 'handles network errors' do
    UDPSocket.any_instance.should_receive(:send).and_raise(Exception)
    broadcaster.go
  end

  def broadcast_and_read
    readThread = Thread.new do
      message, addr = socket.recvfrom(1024)
      data << message
    end
    Thread.pass
    broadcaster.go
    readThread.join
  end

  def local_ip
    ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
    ip.ip_address if ip
  end
end

