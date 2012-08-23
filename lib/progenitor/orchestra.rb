module Progenitor
  class Orchestra

    def initialize
      @players = {}
    end

    def register(player, hears, plays)
      hears.each do |event|
        @players[event] ||= []
        @players[event] << player
      end
    end

    def play(event, value)
      @players[event].each do |player|
        player.hear(event, value)
      end
    end

  end
end
