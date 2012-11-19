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
      attr_accessor :callback_port, :hears, :plays, :device_type, :system_version
      def initialize(data)
        index = super(data)
        @callback_port = data[index+=1]
        @hears = data[index+=1]
        @plays = data[index+=1]
        @device_type = data[index+=1]
        @system_version = data[index+=1]
        index
      end
    end

    def self.build(raw)
      case Message.new(raw).message_type
      when "event"
        EventMessage.new(raw)
      when "register"
        RegisterMessage.new(raw)
      end
    end

    def self.parse(raw)
      message_array = JSON::parse(raw)
      message = build(message_array)
      message
    end

    def self.build_event(spalla_id, event_name, event_value)
      ["event", spalla_id, event_name, event_value].to_json
    end

    def self.build_register(spalla_id, callback_port, hears, plays)
      ["register", spalla_id, callback_port, hears, plays].to_json
    end
  end
end

