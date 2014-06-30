#Copyright (c) 2014, IDEO 

require 'noam_server/grabbed_lemmas'
require 'noam_server/noam_logging'
require 'noam_server/unconnected_lemmas'
require 'noam/sorting'

module NoamServer
  class Orchestra
    attr_reader :players, :events, :last_modified

    def self.instance
      @instance ||= self.new
    end

    def initialize
      @players = {}
      @connections = {}
      @events = {}
      @play_callbacks = []
      @register_callbacks = []
      @unregister_callbacks = []
			@last_modified = Time.now.utc
    end

    def clear
      keys = @players.keys()
      keys.each do |spalla_id|
        fire_player(spalla_id)
      end
    end

    def register(player_connection, player)
      spalla_id = player.spalla_id

      players[spalla_id] = player
      @connections[spalla_id] = player_connection

      fired = []
      player.hears.each do |event|
        @events[event] ||= {}
        fired << @events[event][spalla_id]
        @events[event][spalla_id] = player_connection
      end
      fired.compact.uniq.each(&:terminate)

      UnconnectedLemmas.instance.delete(spalla_id)

			update_last_modified

      player.plays.each do |event|
        @events[event] ||= {}
      end

      @register_callbacks.each do |callback|
        callback.call(player)
      end
    end

    def fire_player(spalla_id)
      player = players.delete(spalla_id)

      connection = @connections.delete(spalla_id)
      connection.terminate if connection

      @events.delete_if do |event, actors|
        actors.delete(spalla_id)
        actors.empty?
      end

			update_last_modified

			@unregister_callbacks.each do |callback|
        callback.call(player)
      end
    end

    def heartbeat(player_id)
      NoamLogging.debug(self, "Got heatbeat from " + player_id)
      player = players[player_id]
      player.last_activity = DateTime.now unless player.nil?
      if player.send_heartbeat_acks?
        connection = @connections[player_id]
        connection.send_heartbeat_ack(player_id)
      end
    end

    def check_heartbeats()
      now = DateTime.now.to_time
      players.dup.each do |spalla_id, player|
        if player.get_heartbeat_rate > 0
          time_since_heartbeat = now - player.last_activity.to_time
          if time_since_heartbeat > player.get_heartbeat_rate * 2
            NoamLogging.info(self, "Failed to get heartbeat of " + spalla_id + ": " + time_since_heartbeat.to_f.to_s + " seconds since activity.")
            fire_player(player.spalla_id)
          end
        end
      end
    end

    def event_names
      @events.keys.sort
    end

    def can_play?(player_id)
      player = players[player_id]
      return (player_id == :web_ui_lemma) || (player && player.in_right_room?)
    end

    def play(event, value, player_id)
      return if !can_play?(player_id)

      player = players[player_id]
      player.learn_to_play(event) unless player.nil?
      player.last_activity = DateTime.now unless player.nil?
      @events[event] ||= {}

      # We need to dup here since #fire_player can mutate the underlying hashes
      @events[event].dup.each do |id, player_connection|
        begin
          player_connection.send_event(player_id, event, value)
        rescue => e
          NoamLogging.warn(self, "Error trying to notify player (#{id}) of event (#{event}). Firing them.")
          stackTrace = e.backtrace.join("\n  == ")
          NoamLogging.debug(self, "Error: #{e.to_s}\n Stack Trace:\n == #{stackTrace}")
          fire_player(id)
        end
      end

      @play_callbacks.each do |callback|
        callback.call(event, value, player)
      end
    end

    def on_register(&callback)
      @register_callbacks << callback
    end

    def on_unregister(&callback)
      @unregister_callbacks << callback
    end

    def on_play(&callback)
      @play_callbacks << callback
    end

    def players_for(spalla_ids)
      spalla_ids ||= []
      valid_players = players.select{ |spalla_id, player| spalla_ids.include? spalla_id }.values
    end

    def spalla_ids
      players.values.map( &:spalla_id )
		end

		def get_players(order=nil)
			return Noam::Sorting.run(players,order) if order
			return players.dup
		end

		private

		def update_last_modified
			@last_modified = Time.now.utc
		end

  end
end
