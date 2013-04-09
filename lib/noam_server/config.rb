CONFIG = {}
CONFIG[:broadcast_port] = 1030
CONFIG[:listen_port] = 7733
CONFIG[:web_socket_port] = 8089
CONFIG[:rsa_private_key] = File.expand_path(File.join(File.dirname(__FILE__), "..", ".ssh", "noam-key"))
CONFIG[:assets_location] = "/Users/progenitor/Dropbox/Ford Progenitor/Phase 2/Code/application_versions"

require 'noam_server/persistence/memory'
CONFIG[:persistor_class] = NoamServer::Persistence::Memory
# NOTE: to run riak, use:
# require 'noam_server/persistence/riak'
# CONFIG[:persistor_class] = Persistence::Riak

CONFIG[:riak] = {:host => 'localhost'}
# NOTE: when using riak, point it at the host (or nodes!)
# CONFIG[:riak] = {:host => '54.235.198.53'}
