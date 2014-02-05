module NoamServer
  class AttenuatedPlayerConnection

    def initialize( ear, min_interval )
      @ear = ear
      @min_interval = min_interval
      @last_send_time = {}
      @last_send_time.default = Time.new(0)
      @last_sent_value = {}
      @last_sent_id = {}
    end

    def hear( id, name, value, now = Time.now )
      remaining = time_left(now, name)
      if remaining <= 0
        try_hear(id, name, value, now)
      else
        @timer.cancel if @timer
        @timer = EM::Timer.new(remaining) do
          try_hear( id, name, value, now + remaining )
        end
      end
    end

    def terminate
      @ear.terminate
    end

    private

    def time_left(now, event_name)
      ( @last_send_time[event_name] + @min_interval ) - now
    end

    def try_hear(id, name, value, now)
      @last_sent_value[name] = value
      @last_sent_id[name] = id

      if @ear.hear( id, name, value )
        @last_send_time[name] = now
      else
        @ear.new_connection do
          @ear.hear( @last_sent_id[name], name, @last_sent_value[name] )
          @last_send_time[name] = now
        end
      end
    end
  end
end
