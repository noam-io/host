require 'noam_server/reapable_repository'
require 'set'

module NoamServer
  class GrabbedLemmas < ReapableRepository

    def self.instance
      @instance ||= self.new()
    end

    def initialize(elements = {})
      super(elements)
    end

    def add(element)
      # TODO : Add as super.add(element) or similar
      @elements[element[:name]] = element
      UdpListener::sendMaro(element[:ip], element[:port])
    end

    def delete(element_id)
      element = get(element_id)
      if !element.nil?
        # TODO : Add as super.delete(element_id) or similar
        @elements.delete(element[:name])
        Orchestra.instance.fire_player(element[:name])
        return true
      else
        return false
      end
    end
  end
end
