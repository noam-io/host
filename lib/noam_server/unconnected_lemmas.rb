module NoamServer
  class UnconnectedLemmas
    def self.instance
      @instance ||= self.new
    end

    def self.reap
      instance.reap
    end

    def initialize(lemmas = {})
      @lemmas = lemmas
    end

    def get(lemma_id)
      @lemmas[lemma_id]
    end

    def add(lemma)
      @lemmas[lemma[:name]] = lemma
    end

    def delete(lemma_id)
      @lemmas.delete(lemma_id)
    end

    def clear
      @lemmas.clear
    end

    def reap
      staleness_timeout = 10
      staleness_threshold = Time.now.getutc - staleness_timeout
      @lemmas.dup.each_pair do |lemma_id, info|
        if info[:last_activity_timestamp] < staleness_threshold
          @lemmas.delete(lemma_id)
        end
      end
    end
  end
end
