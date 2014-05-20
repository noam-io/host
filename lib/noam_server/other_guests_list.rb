require 'noam_server/noam_server'
require 'noam_server/noam_logging'

module NoamServer
  class OtherGuestsList

    def initialize(servers)
      @server_list = servers
      @server_list.on_change do
        @server_list.get_all.each do |name, server|
          if name != NoamServer.room_name
            NoamLogging.info(self, "#{name} #{NoamServer.room_name}")
            request_lemmas(server)
          end
        end
      end
    end

    def request_lemmas(server)
      http = EventMachine::Protocols::HttpClient.request(
        :host => server[:ip],
        :port => server[:http_port],
        :request => "/guests",
        :query_string => "types=[owned]"
      )
      http.callback {|response|
      NoamLogging.info(self, "Response from other server: #{response.inspect}")
        #populate local other list with those lemmas
      }

    end


  end
end
