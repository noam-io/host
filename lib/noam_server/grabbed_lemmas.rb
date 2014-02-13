require 'set'

module NoamServer
  class GrabbedLemmas
    def self.instance
      @instance ||= self.new([])
    end

    def initialize(lemmas)
      @lemmas = Set.new(lemmas)
    end

    def add(element)
      @lemmas.add(element)
    end

    def include?(element)
      @lemmas.include?(element)
    end

    def release(element)
      @lemmas.delete(element)
    end

    def clear
      @lemmas.clear
    end
  end
end
