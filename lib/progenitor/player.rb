module Progenitor
  class Player
    attr_accessor :spalla_id, :remote_client_ip, :remote_port

    def initialize(id)
      @spalla_id = id
    end

  end
end
