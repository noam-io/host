require 'socket'

module NoamServer
  class UdpBroadcaster
    def initialize(broadcast_port, listen_port)
      @listen_port = listen_port
      @broadcast_port = broadcast_port
      @socket = UDPSocket.new
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      Logging.logger[self].info { "UDP Broadcaster broadcasting on port #{@broadcast_port}" }
      Logging.logger[self].info { "UDP Broadcaster listening on port #{@listen_port}" }
      Logging.logger[self].debug { "UDP Broadcaster broadcasting to 127.0.0.1" }
      broadcast_addresses.each do |address|
        Logging.logger[self].debug { "UDP Broadcaster broadcasting to #{address}" }
      end
    end

    def go
      message_to_broadcast = "[Maestro@#{@listen_port}]"
      broadcast_addresses.each do |address|
        send_message_to( message_to_broadcast, address, @broadcast_port )
        #p 'wtf: ' + @broadcast_port.to_s
      end

      send_message_to( message_to_broadcast, '127.0.0.1', @broadcast_port )
      Logging.logger[self].debug { "Broadcasting UDP Message: '#{message_to_broadcast}'" }
    end

    private

    def send_message_to( message, ip, port )
      @socket.send(message, 0, ip, port)
    rescue Exception => e
    end


    def broadcast_addresses
      `ifconfig | grep broadcast`.split($/).map(&:split).map(&:last).uniq
    end
  end
end

