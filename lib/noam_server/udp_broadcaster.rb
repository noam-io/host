require 'socket'
require 'noam_server/noam_logging'

module NoamServer
  class UdpBroadcaster

    @@name = self.to_s.split("::").last

    def initialize(broadcast_port, listen_port)
      @listen_port = listen_port
      @broadcast_port = broadcast_port
      @socket = UDPSocket.new
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      NoamLogging.info(@@name, "UDP Broadcaster broadcasting on port #{@broadcast_port}")
      NoamLogging.info(@@name, "UDP Broadcaster listening on port #{@listen_port}")
      NoamLogging.debug(@@name, "UDP Broadcaster broadcasting to 127.0.0.1")
      broadcast_addresses.each do |address|
        NoamLogging.debug(@@name, "UDP Broadcaster broadcasting to #{address}")
      end
    end

    def go
      message_to_broadcast = "[Maestro@#{@listen_port}]"
      broadcast_addresses.each do |address|
        send_message_to( message_to_broadcast, address, @broadcast_port )
        #p 'wtf: ' + @broadcast_port.to_s
      end

      send_message_to( message_to_broadcast, '127.0.0.1', @broadcast_port )
      NoamLogging.debug(@@name, "Broadcasting UDP Message: '#{message_to_broadcast}'")
    end

    private

    def send_message_to( message, ip, port )
      begin
        @socket.send(message, 0, ip, port)
      rescue Exception => e
        stackTrace = e.backtrace.join("\n  == ")
        NoamLogging.warn(@@name, "Error: #{e.to_s}\n Stack Trace:\n == #{stackTrace}")
      end
    end


    def broadcast_addresses
      `ifconfig | grep broadcast`.split($/).map(&:split).map(&:last).uniq
    end
  end
end

