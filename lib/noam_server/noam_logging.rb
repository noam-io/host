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

    def self.add(*args)
      instance.add(*args)
    end

    def self.start_up
      instance.start_up
    end

    def self.shutdown
      instance.shutdown
    end

    def self.instance
      @instance ||= self.new
    end

    def initialize(logging_config = CONFIG[:logging])
      @logger_class = Logging.logger
      @logger_class.root.level = logging_config[:level]
      @logger_class.root.appenders = logging_config[:appenders]

      @queue = Queue.new
    end

    def add(obj, severity, msg)
      if @shutdown
        return
      end
      @queue << [obj, severity, msg]
    end

    def start_up
      @shutdown = false
      @thread = Thread.new do
        process_queue
      end
    end

    def shutdown
      if @shutdown
        return
      end
      @shutdown = true
      @queue << :stop
      @thread.join
    end

    private
    def process_queue
      while true
        val = @queue.pop
        if val == :stop
          break
        end
        @logger_class[val[0]].add(val[1], val[2])
      end
    end
  end
end
