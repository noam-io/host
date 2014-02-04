######
#  Noam Logging
#  --------------
#  Abstracts logging to a single static asynchronous class.
#  Allows for longer I/O logging such as files and databases by separating out the calls to
#  a threaded event loop.  Uses the 'logging' gem to facilitate multiple outputs and better
#  logging context.
#
#  See config.rb for configuration details. Uses CONFIG['logging'].
#

require 'noam_server/config'
require 'thread'
require 'logging'

module NoamServer
	class NoamLogging

		# Exposed to facilitate testing
		@@loggerClass = Logging.logger

		@@MaxPerIteration = 10
		@@SecondsBetweenIteration = 0.1

    @@shutdown = false
    @@queue = Queue.new

		def self.start_up()
			@@loggerClass.root.level = CONFIG[:logging][:level]
			@@loggerClass.root.appenders = CONFIG[:logging][:appenders]

			@@shutdown = false

			@@thread = Thread.new do
				process_queue
			end
		end

		def self.process_queue()
			while true
				val = @@queue.pop
				if val == :stop
					break
				end
				@@loggerClass[val[0]].add(val[1], val[2])
			end
		end

		def self.shutdown()
			if @@shutdown
				return
			end
			@@shutdown = true
			@@queue << :stop
			@@thread.join
		end

		def self.add(obj, severity, msg = nil)
			if @@shutdown
				return
			end
			@@queue << [obj, severity, msg]
		end

		def self.debug(obj, msg=nil)
			add(obj, ::Logging::LEVELS["debug"], msg)
		end

		def self.info(obj, msg=nil)
			add(obj, ::Logging::LEVELS["info"], msg)
		end

		def self.warn(obj, msg=nil)
			add(obj, ::Logging::LEVELS["warn"], msg)
		end

		def self.error(obj, msg=nil)
			add(obj, ::Logging::LEVELS["error"], msg)
		end

		def self.fatal(obj, msg=nil)
			add(obj, ::Logging::LEVELS["fatal"], msg)
			shutdown
		end
	end
end
