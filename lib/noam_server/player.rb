module NoamServer
  class Player
    attr_accessor :last_activity
    attr_reader :spalla_id, :device_type, :system_version, :hears, :plays, :host, :port
    def device_key
      (@device_type || "").downcase
    end

    def initialize(spalla_id, device_type, system_version, hears, plays, host, port)
      @spalla_id = spalla_id
      @device_type = device_type
      @system_version = system_version
      @hears = hears || []
      @plays = plays || []
      @host = host
      @port = port
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
