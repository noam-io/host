module NoamServer
  class ReapableRepository
    def initialize(elements = {})
      @elements = elements
    end

    def get(element_id)
      @elements[element_id]
    end

    def add(element)
      @elements[element[:name]] = element
    end

    def delete(element_id)
      @elements.delete(element_id)
    end

    def clear
      @elements.clear
    end

    def to_s
      @elements.inspect
    end

    def reap
      staleness_timeout = 10
      staleness_threshold = Time.now.getutc - staleness_timeout
      @elements.dup.each_pair do |element_id, info|
        if info[:last_activity_timestamp] < staleness_threshold
          @elements.delete(element_id)
        end
      end
    end
  end
end

