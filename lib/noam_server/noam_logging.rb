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

		def self.start_up()
			@@loggerClass.root.level = CONFIG[:logging][:level]
			@@loggerClass.root.appenders = CONFIG[:logging][:appenders]

			@@mutex = Mutex.new()
			@@queue ||= Array.new()
			@@shutdown = false
			
			@@thread = Thread.new do
				process_queue
			end
		end

		def self.process_queue()
			while !@@shutdown
				numLeft = [0, @@queue.length - @@MaxPerIteration].max
				while @@queue.length > numLeft
					val = ""
					@@mutex.synchronize do
						val = @@queue.shift()
					end
					@@loggerClass[val[0]].add(val[1], val[2])
				end
				sleep(@@SecondsBetweenIteration)
			end
		end

		def self.shutdown()
			if @@shutdown
				return
			end

			while @@queue.length > 0
				val = ""
				@@mutex.synchronize do
					val = @@queue.shift()
				end
				@@loggerClass[val[0]].add(val[1], val[2])
			end
			@@shutdown = true
			@@thread.join
		end

		def self.add(obj, severity, msg = nil)
			if @@shutdown
				return
			end
			@@mutex.synchronize do
				@@queue.push([obj, severity, msg])
			end
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