require 'progenitor/orchestra'
require 'orchestra/messages'
require 'progenitor/ear'
require 'progenitor/player_connection'
require 'progenitor/player'
module Progenitor

  class MessageHandler
    def initialize(ip)
      @ip = ip
    end

    def message_received(message)
      if message.is_a?(::Orchestra::Messages::RegisterMessage)
        player = Player.new( message.spalla_id, message.device_type, message.system_version, message.hears, message.plays)

        ear = Ear.new(@ip, message.callback_port)
        player_connection = PlayerConnection.new( ear )

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
