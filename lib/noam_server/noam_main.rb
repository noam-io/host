require 'config'
require 'noam_server/persistence/factory'
require 'noam_server/noam_logging'
require 'noam_server/udp_broadcaster'
require 'noam_server/noam_server'
require 'noam_server/web_socket_server'

module NoamServer
	class NoamMain
		attr_accessor :config

		def initialize()

			@config = CONFIG
			NoamLogging.instance(@config[:logging])
			NoamLogging.start_up

			unless CONFIG[:persistor_class].nil?
				NoamLogging.info(self, "Using Persistence Class: #{CONFIG[:persistor_class]}")
				unless Persistence::Factory.get(@config).connected
					NoamLogging.fatal(self, "Unable to connect to persistent store.")
					exit
				end
			else
				NoamLogging.info(self, "Not using Persistent Storage.")
			end

			@server = NoamServer.new(@config[:listen_port])
			@webserver = WebSocketServer.new(@config[:web_socket_port])
			@broadcaster = UdpBroadcaster.new(	@config[:broadcast_port],
			                                    @config[:listen_port])
		end

		def start()
			begin
				@server.start
				@webserver.start
			rescue Errno::EADDRINUSE
				fire_server_started_callback
				exit
			rescue Exception => e
				NoamLogging.fatal(self, "Exiting due to bad startup.")
				NoamLogging.error(self, "Startup Error: " + e.to_s)
				raise
			end

			EventMachine.add_periodic_timer(2) do
				@broadcaster.go
			end
		end

	end
end


####
# Default Noam Callbacks
##########################
NoamServer::Orchestra.instance.on_play do |name, value, player|
  unless CONFIG[:persistor_class].nil?
    persistor = NoamServer::Persistence::Factory.get(CONFIG)
    EM::defer {
      begin
        Timeout::timeout(15) {
          # This ignores saving of messages from noam server
          # TODO : should create player for web view
          persistor.save(name, value, player.spalla_id) unless player.nil?
          NoamServer::NoamLogging.debug('Persistor', "Stored Data Entry in '#{player.spalla_id}' : [" + value.to_s + ", timestamp:" + Time.now.to_i.to_s + "]")
        }
      rescue => error
        NoamServer::NoamLogging.error('Persistor', "Unstored Data Entry in '#{player.spalla_id}' : [" + value.to_s + ", timestamp:" + Time.now.to_i.to_s + "]")
        stackTrace = error.backtrace.join("\n  == ")
        NoamServer::NoamLogging.error('Persistor', "Error: #{error.to_s}\nStack: \n == #{stackTrace}")
      end
    }
  else
    NoamServer::NoamLogging.debug('Orchestra', "#{player.spalla_id} sent '#{name}' = #{value}")
  end
end

NoamServer::Orchestra.instance.on_register do |player|
  NoamServer::NoamLogging.info('Orchestra', "[Registration] From #{player.spalla_id}")
end

NoamServer::Orchestra.instance.on_unregister do |player|
  NoamServer::NoamLogging.info('Orchestra', "[Disconnection] #{player.spalla_id}") if player
end

