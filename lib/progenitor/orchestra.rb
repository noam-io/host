module Progenitor
  class Orchestra
    attr_reader :players

    def self.instance
      @instance ||= self.new
    end

    def initialize
      @players = {}
      @play_callbacks = []
      @register_callbacks = []
    end

    def register(player, hears, plays)
      fired = []
      hears.each do |event|
        @players[event] ||= {}
        fired << @players[event][player.spalla_id]
        @players[event][player.spalla_id] = player
      end
      fired.compact.uniq.each(&:terminate)

      @register_callbacks.each do |callback|
        callback.call(player, hears, plays)
      end
    end

    def play(event, value)
      @players[event].each do |id, player|
        player.hear(event, value)
      end if @players[event]

      @play_callbacks.each do |callback|
        callback.call(event, value)
      end
    end

    def on_register(&callback)
      @register_callbacks << callback
    end

    def on_play(&callback)
      @play_callbacks << callback
    end

  end
end
