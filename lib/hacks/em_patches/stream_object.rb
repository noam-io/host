#Copyright (c) 2014, IDEO 

require 'em/pure_ruby'

# Patching #eventable_read and #eventable_write to rescue more exceptions that
# imply the stream has been closed. The only code that's patched here is the
# list of exceptions to catch in the last rescue branch. EM had only EOFError,
# Errno::ECONNRESET, Errno::ECONNREFUSED, but we've seen at least Errno::EPIPE
# in addition (when a Spark Core running the Arduino lemma loses its
# connection). So while we're at it, let's rescue any potentially-fatal network
# error. Doing the same thing for UDP as well. If we introduce any other kinds
# of sockets those probably have to be patched too.
module EventMachine
  class StreamObject < Selectable
    def eventable_read
      @last_activity = Reactor.instance.current_loop_time
      begin
        if io.respond_to?(:read_nonblock)
          10.times {
            data = io.read_nonblock(4096)
            EventMachine::event_callback uuid, ConnectionData, data
          }
        else
          data = io.sysread(4096)
          EventMachine::event_callback uuid, ConnectionData, data
        end
      rescue Errno::EAGAIN, Errno::EWOULDBLOCK
        # no-op
      rescue EOFError, SystemCallError
        @close_scheduled = true
        EventMachine::event_callback uuid, ConnectionUnbound, nil
      end

    end

    def eventable_write
      @last_activity = Reactor.instance.current_loop_time
      while data = @outbound_q.shift do
        begin
          data = data.to_s
          w = if io.respond_to?(:write_nonblock)
                io.write_nonblock data
              else
                io.syswrite data
              end
          if w < data.length
            @outbound_q.unshift data[w..-1]
            break
          end
        rescue Errno::EAGAIN
          @outbound_q.unshift data
        rescue EOFError, SystemCallError
          @close_scheduled = true
          @outbound_q.clear
        end
      end
    end
  end
end
