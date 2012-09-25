require 'socket'

module Progenitor
  class UdpBroadcaster
    def initialize(port)
      @port = port
      @socket = UDPSocket.new
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    end

    def go
      network_interfaces.each do |network|
        ip = network.ip_address
        broadcast_ip = to_broadcast( ip )
        @message_to_broadcast = "[Maestro@#{ip}:#{@port}]"
        @socket.send(@message_to_broadcast, 0, broadcast_ip, @port)
      end
    rescue Exception => e
      p "Error broadcasting Maestro's location over UDP."
    end

    private

    def network_interfaces
      Socket.ip_address_list.select{|interface| interface.ipv4_private?}
    end

    def to_broadcast( ip )
      ip.gsub(/^(\d+\.\d+\.\d+\.)\d+$/, '\1255')
    end
  end
end

