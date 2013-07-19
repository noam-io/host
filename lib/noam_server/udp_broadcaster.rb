require 'socket'

module NoamServer
  class UdpBroadcaster
    def initialize(broadcast_port, listen_port)
      @listen_port = listen_port
      @broadcast_port = broadcast_port
      @socket = UDPSocket.new
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    end

    def go
      message_to_broadcast = "[Maestro@#{@listen_port}]"
      broadcast_addresses.each do |address|
        send_message_to( message_to_broadcast, address, @broadcast_port )
        #p 'wtf: ' + @broadcast_port.to_s
      end

      send_message_to( message_to_broadcast, '127.0.0.1', @broadcast_port )
    end

    private

    def send_message_to( message, ip, port )
      @socket.send(message, 0, ip, port)
    rescue Exception => e
    end


    def broadcast_addresses
      `ifconfig | grep broadcast`.split($/).map(&:split).map(&:last)
    end
  end
end

