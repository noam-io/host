#Copyright (c) 2014, IDEO 

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
        room_name = if UnconnectedLemmas.instance.include?(message.spalla_id)
          UnconnectedLemmas.instance.get(message.spalla_id)[:desired_room_name]
        else
          NoamServer.room_name
        end
        player = Player.new(message.spalla_id,
                            message.device_type,
                            message.system_version,
                            message.hears,
                            message.plays,
                            0,
                            message.callback_port,
                            room_name,
                            message.options)
        ear = WebSocketEar.new(@web_socket)
        player_connection = PlayerConnection.new( ear )
        orchestra.register(player_connection, player)
      elsif message.is_a?(Noam::Messages::HeartbeatMessage)
        orchestra.heartbeat(message.spalla_id)
      elsif message.is_a?(Noam::Messages::EventMessage)
        orchestra.play(message.event_name, message.event_value, message.spalla_id)
      end
    end

    def orchestra
      Orchestra.instance
    end
  end
end
