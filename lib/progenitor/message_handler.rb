require 'progenitor/player'
module Progenitor
  class MessageHandler
    def initialize(orchestra)
      @orchestra = orchestra
    end

    def message_received(message)
      @orchestra.register(Player.new(message.spalla_id), message.hears, message.plays)
    end
  end
end
