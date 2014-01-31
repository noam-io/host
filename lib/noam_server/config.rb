CONFIG = {}
CONFIG[:web_server_port] = 8081
CONFIG[:broadcast_port] = 1030
CONFIG[:listen_port] = 7733
CONFIG[:web_socket_port] = 8089
CONFIG[:rsa_private_key] = File.expand_path(File.join(File.dirname(__FILE__), "..", ".ssh", "noam-key"))
CONFIG[:assets_location] = "/Users/progenitor/Dropbox/Ford Progenitor/Phase 2/Code/application_versions"

# NOTE: to run riak, use:
# require 'noam_server/persistence/riak'
# CONFIG[:persistor_class] = NoamServer::Persistence::Riak

# NOTE: when using riak, you can point it at a single host:
# CONFIG[:riak] = {:host => '1.1.1.1'}
# CONFIG[:riak] = {:host => 'localhost'}
# or point it at a set of nodes that will be round-robin retried on failure:
# CONFIG[:riak] = {:nodes => [{:host => '54.225.87.37'}, {:host => '54.225.98.124'}, {:host => '54.225.202.245'}]}

# Noam Logging Configurations
require 'logging'
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
CONFIG[:logging][:pattern] = '[%d] [%-10c] [%-5l] %m\n'

# Appenders to use for Logging
CONFIG[:logging][:appenders] = [
	Logging.appenders.stdout(
		:layout => Logging.layouts.pattern(
			:pattern => CONFIG[:logging][:pattern],
			:color_scheme => :default
		)
	),

	# Log Messages to a single file
	# Logging.appenders.file(
	#	'noam.log',
	#	:layout => Logging.layouts.pattern(:pattern => CONFIG[:logging][:pattern])
	# ),

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
