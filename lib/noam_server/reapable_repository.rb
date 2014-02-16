module NoamServer
  class ReapableRepository
    def initialize(elements = {})
      @elements = elements
      @change_callbacks = []
    end

    def on_change(&callback)
      @change_callbacks << callback
    end

    def run_callbacks()
      @change_callbacks.each do |callback|
        callback.call()
      end
    end

    def getAll()
      @elements
    end

    def get(element_id)
      @elements[element_id]
    end

    # Add Element to repository
    # If element is not found add it
    # Otherwise, if the ip is the same as the found one, update the last activity
    def add(element)
      if !include?(element[:name])
        @elements[element[:name]] = element
        run_callbacks()
      elsif element[:ip] == @elements[element[:name]][:ip]
        @elements[element[:name]][:last_activity_timestamp] = element[:last_activity_timestamp]
      end
    end

    def include?(element_id)
      !@elements[element_id].nil?
    end

    def delete(element_id)
      unless @elements.delete(element_id).nil?
        run_callbacks()
      end
    end

    def clear
      @elements.clear
      run_callbacks()
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

