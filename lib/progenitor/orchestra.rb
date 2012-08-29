module Progenitor
  class Orchestra
    attr_reader :players

    def initialize
      @players = {}
    end

    def register(player, hears, plays)
      hears.each do |event|
        @players[event] ||= {}
        @players[event][player.spalla_id] = player
      end
    end

    def play(event, value)
      @players[event].each do |id, player|
        player.hear(event, value)
      end
    end

  end
end
