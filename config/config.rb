#Copyright (c) 2014, IDEO 

require 'logging'
require 'socket'

CONFIG = {}
CONFIG[:room_name] = ""
CONFIG[:web_server_port] = 8081
CONFIG[:broadcast_port] = 1030
CONFIG[:listen_port] = 7733
CONFIG[:web_socket_port] = 8089

# Web Server Config
CONFIG[:web_server] = {
	:time_to_timeout => 10
}

# Persistor Types
# CONFIG[:persistor_class] = :riak
# CONFIG[:persistor_class] = :memory
# CONFIG[:persistor_class] = :mongodb

# Riak Settings
# NOTE: when using riak, you can point it at a single host:
# CONFIG[:riak] = {:host => '1.1.1.1'}
CONFIG[:riak] = {:host => 'localhost'}
# or point it at a set of nodes that will be round-robin retried on failure:
# CONFIG[:riak] = {:nodes => [{:host => '54.225.87.37'}, {:host => '54.225.98.124'}, {:host => '54.225.202.245'}]}

# MongoDB Settings
CONFIG[:mongodb] = { :ip => 'localhost', :port => 27017, :db => 'noam-server-data' }


# Noam Logging Configurations

CONFIG[:logging] = { }

# Level of logging to use by default
CONFIG[:logging][:level] = :info

# Pattern to use for all logging messages
#    %d - date
#    %c - calling class
#    %l - message level
#    %m - message string
#
#    For full list of options, see:
#		https://github.com/TwP/logging/blob/master/lib/logging/layouts/pattern.rb
#
CONFIG[:logging][:pattern] = '[%d] [%-15c] [%-5l] %m\n'

# Appenders to use for Logging
CONFIG[:logging][:appenders] = [
  Logging.appenders.stdout(
    :layout => Logging.layouts.pattern(
      :pattern => CONFIG[:logging][:pattern],
      :color_scheme => :default
    )
  ),

  # Log Messages to a single file
  Logging.appenders.file(
    '/tmp/noam.log',
    :layout => Logging.layouts.pattern(:pattern => CONFIG[:logging][:pattern])
  ),

  # Log messages to a rolling file based on size
  #   Set to a max of 100KB and keep up to 3 files at a time
  #
  # Logging.appenders.rolling_file(
  #	'noam.log',
  #	:layout => Logging.layouts.pattern(:pattern => CONFIG[:logging][:pattern]),
  #   :size => 1024 * 100,
  #   :keep => 3,
  #   :roll_by => 'number'
  # ),
]
