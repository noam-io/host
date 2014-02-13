require 'config'
require 'noam_server/noam_logging'
require 'noam_server/noam_server'
require 'noam_server/persistence/factory'
require 'noam_server/server_locator'
require 'noam_server/udp_broadcaster'
require 'noam_server/udp_listener'
require 'noam_server/unconnected_lemmas'
require 'noam_server/web_socket_server'

module NoamServer
  class NoamMain
    attr_accessor :config

    def initialize
      @config = CONFIG
      @logger = NoamLogging.instance(@config[:logging])
      @logger.setLevel(@config[:logging][:level])
      @logger.start_up

      persistor = Persistence::Factory.get(@config)
      NoamLogging.info(self, "Using Persistence: #{persistor}")
      unless persistor.connected
        NoamLogging.fatal(self, "Unable to connect to persistent store.")
        EM.stop
      end

      @server = NoamServer.new(@config[:listen_port])
      @webserver = WebSocketServer.new(@config[:web_socket_port])
      # @broadcaster = UdpBroadcaster.new(@config[:broadcast_port],
      #                                   @config[:listen_port])
      #@server_locator = ServerLocator.new(@config[:broadcast_port])
      @marcopolo = UdpListener.new
    end

    def start
      begin
        @server.start
        @webserver.start
      #  @server_locator.start
        @marcopolo.start(@config[:broadcast_port], @config[:listen_port], @config[:server_name])
      rescue Errno::EADDRINUSE
        NoamLogging.warn("Exiting due to ports already being occupied")
        fire_server_started_callback
        EM.stop
      rescue Exception => e
        NoamLogging.fatal(self, "Exiting due to bad startup.")
        NoamLogging.error(self, "Startup Error: " + e.to_s)
        raise
      end

      EventMachine.add_periodic_timer(2) do
        UnconnectedLemmas.reap
        NoamLogging.debug(self, "UnconnectedLemmas: #{UnconnectedLemmas.instance}")
      end
    end

  end
end


####
# Default Noam Callbacks
##########################

# Dummy Player used for Web UI
TempPlayer = Struct.new(:spalla_id)
WebUIPlaceholder = TempPlayer.new("Web UI Lemma")

NoamServer::Orchestra.instance.on_play do |name, value, player|

  unless player
    player = WebUIPlaceholder
  end

  unless CONFIG[:persistor_class].nil?
    persistor = NoamServer::Persistence::Factory.get(CONFIG)
    EM::defer {
      begin
        Timeout::timeout(15) {
          # This ignores saving of messages from noam server
          # TODO : should create player for web view
          unless player.nil?
            persistor.save(name, value, player.spalla_id)
            NoamServer::NoamLogging.debug('Persistor', "Stored Data Entry in '#{player.spalla_id}' : [" + value.to_s + ", timestamp:" + Time.now.to_i.to_s + "]")
          end
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

