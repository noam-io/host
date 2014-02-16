require 'noam_server/reapable_repository'

module NoamServer
  class UnconnectedLemmas < ReapableRepository
    def self.instance
      @instance ||= self.new
    end
  end
end
