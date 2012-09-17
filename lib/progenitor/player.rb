
module Progenitor
  class Player
    attr_reader :hears, :plays
    def initialize(hears, plays)
      @hears = hears || []
      @plays = plays || []
    end

    def hears?(event)
      @hears.include?(event)
    end

    def plays?(event)
      @plays.include?(event)
    end

    def learn_to_play(event)
      @plays << event unless @plays.include?(event)
    end

  end
end
