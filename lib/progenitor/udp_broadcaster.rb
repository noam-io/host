require 'socket'

module Progenitor
  class UdpBroadcaster
    def initialize(port)
      @port = port
      @address = '<broadcast>'
      @message_to_broadcast = "[Maestro@#{local_ip}:#{@port}]"

      @socket = UDPSocket.new
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    end

    def go
      @socket.send(@message_to_broadcast, 0, @address, @port)
    end

    private

    def local_ip
      ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
      ip.ip_address if ip
    end
  end
end

