require 'progenitor/orchestra'
require 'progenitor/messages'
require 'progenitor/player'
module Progenitor

  class MessageHandler
    def initialize(ip)
      @ip = ip
    end

    def message_received(message)
      if message.is_a?(Messages::RegisterMessage)
        player = Player.new(message.spalla_id, @ip, message.callback_port)
        orchestra.register(player, message.hears, message.plays)
      elsif message.is_a?(Messages::EventMessage)
        orchestra.play(message.event_name, message.event_value)
      end
    end

    def orchestra
      Orchestra.instance
    end
  end
end
