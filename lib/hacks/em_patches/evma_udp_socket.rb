#Copyright (c) 2014, IDEO 

require 'em/pure_ruby'

module EventMachine
  class EvmaUDPSocket < DatagramObject
    class << self
      # We need to override this to allow us to listen to UDP on ports that
      # lemmas are already listening on. Lemmas should be set up as
      # SO_REUSEPORT/SO_REUSEADDR where they're intended to run on the same
      # machine.
      def create host, port
        sd = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM, 0)
        sd.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
        sd.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true)
        sd.bind Socket::pack_sockaddr_in(port, host)
        EvmaUDPSocket.new sd
      end
    end

    # We need to override this because the pure_ruby version returns a nil
    # peername by default - which makes sense since UDP is connectionless.
    # Calling this is really only meaningful in the context of #receive_data,
    # but EM's structure doesn't give us an easy way to scope it to that.
    def get_peername
      @return_address
    end

    # For #eventable_write and #eventable_read, see the comments in the
    # StreamObject patch. We just want to rescue some additional errors.
    def eventable_write
      40.times {
        break if @outbound_q.empty?
        begin
          data,target = @outbound_q.first
          io.send data.to_s, 0, target
          @outbound_q.shift
        rescue Errno::EAGAIN
          break
        rescue EOFError, SystemCallError
          @close_scheduled = true
          @outbound_q.clear
        end
      }
    end

    def eventable_read
      begin
        if io.respond_to?(:recvfrom_nonblock)
          40.times {
            data,@return_address = io.recvfrom_nonblock(16384)
            EventMachine::event_callback uuid, ConnectionData, data
            @return_address = nil
          }
        else
          raise "unimplemented datagram-read operation on this Ruby"
        end
      rescue Errno::EAGAIN
        # no-op
      rescue EOFError, SystemCallError
        @close_scheduled = true
        EventMachine::event_callback uuid, ConnectionUnbound, nil
      end
    end
  end
end

