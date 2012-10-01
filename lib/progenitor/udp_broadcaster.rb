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
        message_to_broadcast = "[Maestro@#{ip}:#{@port}]"
        send_message_to( message_to_broadcast, broadcast_ip, @port )
      end
    end

    private

    def send_message_to( message, ip, port )
      @socket.send(message, 0, ip, port)
    rescue Exception => e
    end

    def network_interfaces
      Socket.ip_address_list.select{|interface| interface.ipv4_private?}
    end

    def to_broadcast( ip )
      ip.gsub(/^(\d+\.\d+\.)\d+\.\d+$/, '\1255.255')
    end
  end
end

