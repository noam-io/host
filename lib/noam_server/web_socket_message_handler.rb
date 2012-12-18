require 'noam_server/orchestra'
require 'noam/messages'
require 'noam_server/web_socket_ear'
require 'noam_server/player_connection'
require 'noam_server/player'
module NoamServer

  class WebSocketMessageHandler
    def initialize(web_socket)
      @web_socket = web_socket
    end

    def message_received(message)
      if message.is_a?(Noam::Messages::RegisterMessage)
        player = Player.new( message.spalla_id, message.device_type, message.system_version, message.hears, message.plays, 0, message.callback_port)
        ear = WebSocketEar.new(@web_socket)
        player_connection = PlayerConnection.new( ear )
        orchestra.register(player_connection, player)
      elsif message.is_a?(Noam::Messages::EventMessage)
        orchestra.play(message.event_name, message.event_value, message.spalla_id)
      end
    end

    def orchestra
      Orchestra.instance
    end
  end
end
