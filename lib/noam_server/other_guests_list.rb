require 'noam_server/noam_server'
require 'noam_server/noam_logging'

module NoamServer
  class OtherGuestsList

    def self.instance(servers = nil)
      @instance ||= self.new(servers)
    end

    def initialize(servers)
      @server_list = servers
      @guests = {}
      @server_list.on_change { servers_changed }
    end

    def servers_changed
      clean_servers_list
      request_new_lemma_lists
    end

    def response_handler(server, list)
      guests = list["guests-owned"]
      NoamLogging.debug(self, "Other Guest Response: #{guests.inspect}")
      @guests[server[:name]] =  guests
    end

    def get_all
      @guests.values.reduce(&:merge!) || {}
    end

    def request_lemmas(server)
      http = EventMachine::Protocols::HttpClient.request(
        :host => server[:ip],
        :port => server[:http_port],
        :request => "/guests",
        :query_string => "types=[owned]"
      )
      http.callback { |response|
        response_handler(server, JSON.parse(response[:content]))
      }
    end

    def clean_servers_list
      servers = @server_list.get_all
      @guests.keys.each do |server|
        if !servers.include?(server)
          @guests.delete(server)
        end
      end
    end

    def request_new_lemma_lists
      servers = @server_list.get_all
      servers.each do |name, server|
        if name != NoamServer.room_name
          NoamLogging.info(self, "#{name} #{NoamServer.room_name}")
          request_lemmas(server)
        end
      end
    end


  end
end
