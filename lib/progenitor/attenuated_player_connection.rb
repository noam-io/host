require 'eventmachine'

module Progenitor
  class AttenuatedPlayerConnection

    def initialize( ear, min_interval )
      @ear = ear
      @min_interval = min_interval
      @last_send_time = {}
      @last_send_time.default = Time.new(0)
    end

    def hear( id, name, value, now )
      remaining = time_left(now, name)
      if remaining <= 0
        @ear.hear( id, name, value )
        @last_send_time[name] = now
      else
        @timer.cancel if @timer
        @timer = EM::Timer.new(remaining) do
          @ear.hear( id, name, value )
          @last_send_time[name] = now + remaining
        end
      end
    end

    private

    def time_left(now, event_name)
      ( @last_send_time[event_name] + @min_interval ) - now
    end
  end
end
