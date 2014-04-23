require "em/pure_ruby"
require "noam_server/noam_logging"
require "test_udp_receiver"
require "test_tcp_server"
require "test_websocket_server"
require "test_audience"

module LemmaVerification
  class TestMain

    def self.start(room_name, output_file)
      EM.run do
        TestTcpServer.start(7733)
        TestWebsocketServer.start(8089)
        TestUdpReceiver.start(1030, room_name, 7733)
        # em-websocket declares signal handlers, so we must load these _after_
        # starting our test websocket server
        ["INT", "TERM", "QUIT"].each do |signal|
          trap(signal) do
            EM.stop
            NoamServer::NoamLogging.shutdown
            write_results(output_file)
          end
        end
      end
    end

    def self.write_results(output_file)
      File.open(output_file, "w") { |file| file.write(TestAudience.instance.to_hash.to_json) }
    end

  end
end
