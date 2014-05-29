#Copyright (c) 2014, IDEO

require 'noam_server/reapable_repository'

module NoamServer
  class LocatedServers < ReapableRepository

		def self.instance
      @instance ||= self.new
		end

		def reap
			staleness_timeout = 3
			staleness_threshold = Time.now.getutc - staleness_timeout
			any_changes = false
			@elements.dup.each_pair do |element_id, info|
				if info[:last_modified] > staleness_threshold
					@elements.delete(element_id)
					any_changes = true
				end
			end
			run_callbacks if any_changes
		end

  end
end
