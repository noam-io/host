module NoamServer
  class ReapableRepository

    def initialize(elements = {})
      @elements = elements
      @change_callbacks = []
    end

    def on_change(&callback)
      @change_callbacks << callback
    end

    def run_callbacks
      @change_callbacks.each do |callback|
        callback.call
      end
    end

		def get_all(order=nil)
			return Noam::Sorting.run(@elements,order) if order
			return @elements.dup
    end

    def get(element_id)
      @elements[element_id]
    end

    # Add Element to repository
    # If element is not found add it
    def add(element)
      is_new_element = !include?(element[:name])
      @elements[element[:name]] = element
      if is_new_element
        run_callbacks
      end
    end

    def include?(element_id)
      !@elements[element_id].nil?
    end

    def delete(element_id)
      unless @elements.delete(element_id).nil?
        run_callbacks
      end
    end

    def clear
      @elements.clear
      run_callbacks
    end

    def to_s
      @elements.inspect
    end

    def reap
      staleness_timeout = 10
      staleness_threshold = Time.now.getutc - staleness_timeout
      any_changes = false
      @elements.dup.each_pair do |element_id, info|
        if info[:last_activity_timestamp] < staleness_threshold
          @elements.delete(element_id)
          any_changes = true
        end
      end
      run_callbacks if any_changes
    end
  end
end

