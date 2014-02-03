require 'noam/tcp_listener'
require 'noam_server/message_handler'
require 'noam_server/listener'

module NoamServer
  class NoamServer
    def initialize(port)
      @port = port
      @host = "0.0.0.0"
    end

    def start
      NoamLogging.info(self, "Using Persistence Class: #{CONFIG[:persistor_class]}")
      NoamLogging.info(self, "Starting Noam Server at #{@host}:#{@port}")
      begin
        EventMachine::start_server(@host, @port, Listener)    		
      rescue Errno::EADDRINUSE
        NoamLogging.fatal(self, "Unable to start Noam Server - Server port already in use.")
        raise
      end
    end
  end
end
