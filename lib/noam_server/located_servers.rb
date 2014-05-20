#Copyright (c) 2014, IDEO

require 'noam_server/reapable_repository'

module NoamServer
  class LocatedServers < ReapableRepository
    def self.instance
      @instance ||= self.new
    end
    def same?(existing, current)
      existing[:name] == current[:name] &&
      existing[:last_modified] == current[:last_modified]
    end
  end
end
