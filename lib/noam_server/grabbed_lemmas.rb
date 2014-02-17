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
      self.class.superclass.instance_method(:add).bind(self).call(element)
      @elements[element[:name]] = element
      UdpListener::sendMaro(element[:ip], element[:port])
    end

    def delete(element_id)
      element = get(element_id)
      if !element.nil?
        self.class.superclass.instance_method(:delete).bind(self).call(element_id)
        @elements.delete(element[:name])
        Orchestra.instance.fire_player(element[:name])
        return true
      else
        return false
      end
    end
  end
end
