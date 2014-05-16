#Copyright (c) 2014, IDEO 

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

    def port
      @ear.port
    end

    def host
      @ear.host
    end

    def send_event( id_of_player, event_name, event_value, now = Time.now )
      remaining = time_left(now, event_name)
      if remaining <= 0
        msg = Noam::Messages.build_event( id_of_player, event_name, event_value )
        send_message(id_of_player, event_name, msg, now)
      else
        @timer.cancel if @timer
        @timer = EM::Timer.new(remaining) do
          msg = Noam::Messages.build_event( id_of_player, event_name, event_value )
          send_message(id_of_player, event_name, msg, now + remaining)
        end
      end
    end

    def send_heartbeat_ack( id_of_player, now = Time.now )
      msg = Noam::Messages.build_heartbeat_ack( id_of_player )
      send_message(id_of_player, '__heartbeat', msg, now)
    end

    def terminate
      @ear.terminate
    end

    private

    def time_left(now, event_name)
      ( @last_send_time[event_name] + @min_interval ) - now
    end

    def send_message(id_of_player, name, message, now)
      @last_sent_value[name] = message

      if @ear.send_data(message)
        @last_send_time[name] = now
      end
    end
  end
end
