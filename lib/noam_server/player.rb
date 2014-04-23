
module NoamServer
  class Player

    attr_accessor :last_activity
    attr_reader :spalla_id, :device_type, :system_version, :hears, :plays, :host, :port, :room_name

    def device_key
      (@device_type || "").downcase
    end

    def initialize(spalla_id, device_type, system_version, hears, plays, host, port, room_name, options = {})
      @spalla_id = spalla_id
      @device_type = device_type
      @system_version = system_version
      @hears = hears || []
      @plays = plays || []
      @host = host
      @port = port
      @room_name = room_name
      @options = options
      @last_activity = DateTime.now
      NoamLogging.debug(self, "New Player:")
      NoamLogging.debug(self, "   Hears: #{@hears}")
      NoamLogging.debug(self, "   Plays: #{@plays}")
      NoamLogging.debug(self, "   Plays: #{@room_name}")
    end

    def send_heartbeat_acks?
      @options["heartbeat_ack"] === true
    end

    def get_heartbeat_rate
      @options["heartbeat"] || -1
    end

    def in_right_room?
      @room_name == NoamServer.room_name or @room_name == ''
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
