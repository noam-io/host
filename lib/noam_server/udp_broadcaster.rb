require 'socket'
require 'noam_server/noam_logging'

module NoamServer
  class UdpBroadcaster
    def initialize(broadcast_port, room_name, http_port)
      @http_port = http_port
      @room_name = room_name
      @broadcast_port = broadcast_port
      @socket = UDPSocket.new
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      broadcast_addresses.each do |address|
        log_broadcasting(address)
      end
    end

    def log_broadcasting(address)
      NoamLogging.info(self, "Server beacon broadcasting #{message_to_broadcast.inspect} to #{address}:#{@broadcast_port}")
    end

    def message_to_broadcast
      Noam::Messages.build_server_beacon(@room_name, @http_port)
    end

    def go
      broadcast_addresses.each do |address|
        send_message_to(message_to_broadcast, address, @broadcast_port)
      end
      NoamLogging.debug(self, "Broadcasting UDP Message: '#{message_to_broadcast}'")
    end

    private

    def send_message_to(message, ip, port)
      begin
        @socket.send(message, 0, ip, port)
      rescue Exception => e
        stack_trace = e.backtrace.join("\n  == ")
        NoamLogging.warn(self, "Error: #{e.to_s}\n Stack Trace:\n == #{stack_trace}")
      end
    end


    def broadcast_addresses
      Socket.getifaddrs.
             map(&:broadaddr).
             compact.
             select(&:ipv4?).
             map(&:ip_address).
             uniq
    end
  end
end

