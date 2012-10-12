require 'progenitor/orchestra'
require 'progenitor/messages'
require 'progenitor/player_connection'
require 'progenitor/player'
module Progenitor

  class MessageHandler
    def initialize(ip)
      @ip = ip
    end

    def message_received(message)
      if message.is_a?(Messages::RegisterMessage)
        player_connection = PlayerConnection.new( @ip, message.callback_port )
        player = Player.new( message.spalla_id, message.device_type, message.system_version, message.hears, message.plays)
        orchestra.register(player_connection, player)
      elsif message.is_a?(Messages::EventMessage)
        orchestra.play(message.event_name, message.event_value, message.spalla_id)
      end
    end

    def orchestra
      Orchestra.instance
    end
  end
end
