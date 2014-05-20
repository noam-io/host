module Noam
	class Sorting
		ALPHABETICALLY_ASCENDING = 'asc'
		ALPHABETICALLY_DESCENDING = 'desc'

		def self.run(elems, order=nil)
			return elems.dup.sort.to_h if order == ALPHABETICALLY_ASCENDING
			return elems.dup.sort.reverse.to_h if order == ALPHABETICALLY_DESCENDING
		end

	end
end