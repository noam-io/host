module NoamServer
  class UnconnectedLemmas
    def self.instance
      @instance ||= {}
    end

    def self.reap
      staleness_timeout = 10
      staleness_threshold = Time.now.getutc - staleness_timeout
      instance.dup.each_pair do |lemma_id, info|
        if info[:last_activity_timestamp] < staleness_threshold
          instance.delete(lemma_id)
        end
      end
    end
  end
end
