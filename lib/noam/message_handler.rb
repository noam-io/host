require 'noam/orchestra'
require 'orchestra/messages'
require 'noam/ear'
require 'noam/player_connection'
require 'noam/attenuated_player_connection'
require 'noam/player'
module Noam

  class MessageHandler
    def initialize(ip)
      @ip = ip
    end

    def message_received(message)
      if message.is_a?(::Orchestra::Messages::RegisterMessage)
        player = Player.new( message.spalla_id, message.device_type, message.system_version, message.hears, message.plays, @ip, message.callback_port)

        ear = Ear.new( player.host, player.port )
        player_connection = if message.device_type == "arduino"
          AttenuatedPlayerConnection.new( ear, 0.1)
        else
          PlayerConnection.new( ear )
        end

        orchestra.register(player_connection, player)
      elsif message.is_a?(::Orchestra::Messages::EventMessage)
        orchestra.play(message.event_name, message.event_value, message.spalla_id)
      end
    end

    def orchestra
      Orchestra.instance
    end
  end
end
