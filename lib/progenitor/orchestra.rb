module Progenitor
  class Orchestra
    attr_reader :players, :events

    def self.instance
      @instance ||= self.new
    end

    def initialize
      @players = {}
      @events = {}
      @play_callbacks = []
      @register_callbacks = []
    end

    def register(player_connection, player)
      players[player_connection.spalla_id] = player

      fired = []
      player.hears.each do |event|
        @events[event] ||= {}
        fired << @events[event][player_connection.spalla_id]
        @events[event][player_connection.spalla_id] = player_connection
      end
      fired.compact.uniq.each(&:terminate)

      player.plays.each do |event|
        @events[event] ||= {}
      end

      @register_callbacks.each do |callback|
        callback.call(player_connection, player.hears, player.plays)
      end
    end

    def event_names
      @events.keys
    end

    def play(event, value)
      @events[event].each do |id, player|
        player.hear(event, value)
      end if @events[event]

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
