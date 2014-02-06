require 'em-websocket'
require 'config'
require 'noam_server/noam_logging'
require 'noam_server/web_socket_message_handler'
require 'noam/tcp_listener'

module NoamServer
  class WsConnection
    attr_accessor :listener, :spalla_id

    def post_init(web_socket)
      handler = WebSocketMessageHandler.new(web_socket)
      @listener = Noam::TcpListener.new do |msg|
        begin
          parsed_message = Noam::Messages.parse(msg)
          @spalla_id = parsed_message.spalla_id
          handler.message_received(parsed_message)
        rescue JSON::ParserError
          NoamLogging.error(self, "invalid message received:  #{msg}")
        end
      end
    end

    def close
      Orchestra.instance.fire_player( @spalla_id )
    end

    def receive_data data
      listener.receive_data(data)
    end
  end


  class WebSocketServer

    def initialize(port)
      @port = port
      @host = "0.0.0.0"
    end

    def start
      NoamLogging.info(self, "Starting Socket Server at #{@host}:#{@port}")
      begin
          EventMachine::WebSocket.start(:host => @host, :port => @port) do |ws|
          connection = WsConnection.new
          ws.onopen    { connection.post_init(ws) }
          ws.onmessage { |msg| connection.receive_data(msg) }
          ws.onclose   { connection.close }
          ws.onerror do |err|
            NoamLogging.error(self, "Web Socket Error: #{err}")
          end
        end
      rescue Errno::EADDRINUSE => e
        NoamLogging.fatal(self, "Unable to start Socket Server - Port already in use.")
        raise
      end
    end
  end
end
