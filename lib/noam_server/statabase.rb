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

    def set(name, value)
      @values[name] = value
      @timestamps[name] = DateTime.now
    end

    def get(name)
      @values[name] || 0
    end

    def timestamp(name)
      @timestamps[name]
    end
  end
end
