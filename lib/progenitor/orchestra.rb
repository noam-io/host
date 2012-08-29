module Progenitor
  class Orchestra
    attr_reader :players

    def self.instance
      @instance ||= self.new
    end

    def initialize
      @players = {}
    end

    def register(player, hears, plays)
      fired = []
      hears.each do |event|
        @players[event] ||= {}
        fired << @players[event][player.spalla_id]
        @players[event][player.spalla_id] = player
      end
      fired.compact.uniq.each(&:terminate)
    end

    def play(event, value)
      @players[event].each do |id, player|
        player.hear(event, value)
      end
    end

  end
end
