#Copyright (c) 2014, IDEO 

require "em/pure_ruby"
require "noam_server/noam_logging"
require "test_udp_receiver"
require "test_tcp_server"
require "test_websocket_server"
require "test_audience"

module LemmaVerification
  class TestMain

    def self.start(options)
      EM.run do
        TestTcpServer.start(options[:tcp_port])
        TestWebsocketServer.start(options[:web_socket_port])
        TestUdpReceiver.start(options[:udp_port], options[:room_name], options[:tcp_port])
        # em-websocket declares signal handlers, so we must load these _after_
        # starting our test websocket server
        ["INT", "TERM", "QUIT"].each do |signal|
          trap(signal) do
            EM.stop
            NoamServer::NoamLogging.shutdown
            write_results(options[:output_file_path])
          end
        end
      end
    end

    def self.write_results(output_file)
      File.open(output_file, "w") { |file| file.write(TestAudience.instance.to_hash.to_json) }
    end

  end
end
