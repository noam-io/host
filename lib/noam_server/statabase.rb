# Copyright (c) 2014, IDEO

module NoamServer
  class Statabase
    def self.instance
      @instance ||= self.new
    end

    def initialize
      @values = {}
      @timestamps = {}
		end

		def set(name, player_id, value)
			set_values(name, player_id, value)
			set_timestamps(name, player_id)
		end

		def get(name, player_id)
			if @values[name] && @values[name][player_id]
				@values[name][player_id]
			else
				0
			end
		end

		def get_lemmas(name)
			if @values[name]
				@values[name]
			else
				nil
			end
		end

		def timestamp(name, player_id)
			if @timestamps[name] && @timestamps[name][player_id]
				@timestamps[name][player_id]
			else
				nil
			end
		end

		private

		def set_values(name, player_id, value)
			if (@values[name].nil?)
				@values[name] = {player_id => value}
			else
				@values[name][player_id] = value
			end
		end

		def set_timestamps(name, player_id)
			if (@timestamps[name].nil?)
				@timestamps[name] = {player_id => DateTime.now}
			else
				@timestamps[name][player_id] = DateTime.now
			end
		end

  end
end
