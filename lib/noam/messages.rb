#Copyright (c) 2014, IDEO

require 'json'

module Noam
  module Messages

    class Message
      attr_accessor :spalla_id, :message_type
      def initialize(data)
        index = -1
        @message_type = data[index+=1]
        @spalla_id = data[index+=1]
        index
      end
    end

    class NullMessage < Message
      def initialize
        @message_type = "null"
        @spalla_id = nil
      end
    end

    class EventMessage < Message
      attr_accessor :event_name, :event_value

      def initialize(data)
        index = super(data)
        @event_name = data[index+=1]
        @event_value = data[index+=1]
        index
      end

    end

    class RegisterMessage < Message
      attr_accessor :callback_port, :hears, :plays, :device_type, :system_version, :options
      def initialize(data)
        index = super(data)
        @callback_port = data[index+=1]
        @hears = data[index+=1]
        @plays = data[index+=1]
        @device_type = data[index+=1]
        @system_version = data[index+=1]
        @options = data[index+=1] || {}
        index
      end
    end

    class HeartbeatMessage < Message
      def initialize(data)
        index = super(data)
        index
      end
    end

    class HeartbeatAckMessage < Message
      def initialize(data)
        index = super(data)
        index
      end
    end

    class PoloMessage < Message
      attr_accessor :callback_port, :room_name
      def initialize(data)
        index = super(data)
        @callback_port = data[index+=1]
        index
      end

      def room_name
        @spalla_id
      end
    end

    class MarcoMessage < Message
      attr_accessor :room_name, :device_type, :callback_port, :system_version
      def initialize(data)
        index = super(data)
        @room_name = data[index+=1]
        @device_type = data[index+=1]
        @system_version = data[index+=1]
        index
      end
    end

    class ServerBeaconMessage < Message
      attr_accessor :room_name, :http_port, :timestamp
      def initialize(data)
        index = super(data)
        @room_name = @spalla_id
        @http_port = data[index+=1]
        @timestamp = Time.parse(data[index+=1])
        index
      end
    end

    def self.build(raw)
      message = Message.new(raw)
      case message.message_type
      when "event"
        EventMessage.new(raw)
      when "register"
        RegisterMessage.new(raw)
      when "polo"
        PoloMessage.new(raw)
      when "marco"
        MarcoMessage.new(raw)
      when "server_beacon"
        ServerBeaconMessage.new(raw)
      when "heartbeat"
        HeartbeatMessage.new(raw)
      else
        message
      end
    end

    def self.parse(raw)
      message_array = JSON::parse(raw)
      message = build(message_array)
      message
    rescue JSON::ParserError
      return NullMessage.new
    end

    def self.build_event(spalla_id, event_name, event_value)
      ["event", spalla_id, event_name, event_value].to_json
    end

    def self.build_register(spalla_id, callback_port, hears, plays)
      ["register", spalla_id, callback_port, hears, plays].to_json
    end

    def self.build_polo(room_name, callback_port)
      ["polo", room_name, callback_port].to_json
    end

    def self.build_marco(spalla_id, room_name)
      ["marco", spalla_id, room_name, "ruby", "1.1"].to_json
    end

    def self.build_server_beacon(room_name, http_port, timestamp)
      ["server_beacon", room_name, http_port, timestamp].to_json
    end

    def self.build_heartbeat_ack(spalla_id)
      ["heartbeat_ack", spalla_id].to_json
    end
  end
end

