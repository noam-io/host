# Copyright (c) 2014, IDEO

require 'cgi'

require 'noam_server/statabase'

module NoamServer
  class OrchestraState
    def self.new
      data = {players: players, events: events}
      add_message_count(data)
      data
    end

    private

    def self.players
      Orchestra.instance.players.reduce({}) {|hash, (spalla_id, player)|
        hash[spalla_id] = {
          spalla_id:         player.spalla_id,
          device_type:       player.device_type,
          last_activity:     format_utc(player.last_activity),
          system_version:    player.system_version,
          hears:             player.hears,
          plays:             player.plays,
          ip:                player.host,
          desired_room_name: player.room_name
        }
        hash
      }
    end

    def self.events
			hash = {}
			Orchestra.instance.events.each do |event_name, value|
				lemmas = statabase.get_lemmas(event_name)
				if (lemmas)
					hash[event_name] = {}
					lemmas.each do |spalla_id, value|
						hash[event_name][spalla_id] = {
								value_escaped: html_safe(value),
								timestamp: format_utc(statabase.timestamp(event_name, spalla_id))
						}
					end
				end
			end
			hash
		end

    def self.statabase
      @@statabase ||= Statabase.instance
    end

    def self.add_message_count(data)
      count = data[:players].values.reduce(0) {|sum, player| sum += player[:plays].length; sum}
      data[:'number-played-messages'] = count
    end

    def self.format_utc(date)
      if date
        utc_date = date.new_offset(0)
        utc_date.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
      end
    end

    def self.html_safe(value)
      CGI.escape(value.to_s)
    end
  end
end
