require 'socket'

module Progenitor
  class UdpBroadcaster
    def initialize(port)
      @port = port
    end

    def go
      address = '<broadcast>'
      socket = UDPSocket.new
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      socket.send(message_to_broadcast, 0, address, @port)
      socket.close
    end

    private

    def message_to_broadcast
      expected_message = "[Maestro@#{local_ip}:#{@port}]"
    end

    def local_ip
      ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
      ip.ip_address if ip
    end
  end
end

