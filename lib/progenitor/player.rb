
module Progenitor
  class Player
    attr_reader :spalla_id, :device_type, :system_version, :hears, :plays

    def initialize(spalla_id, device_type, system_version, hears, plays)
      @spalla_id = spalla_id
      @device_type = device_type
      @system_version = system_version
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
