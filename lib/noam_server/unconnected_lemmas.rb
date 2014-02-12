module NoamServer
  class UnconnectedLemmas
    def self.instance
      @instance ||= {}
    end
  end
end
