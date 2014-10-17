require 'noam_server/player'
module Noam
  class NullPlayer < NoamServer::Player
    def initialize
      super(:no_lemma_id, "none", "0.0", [], [], "", -1, "")
    end

    def learn_to_play(event)

    end

    def in_right_room?
      true
    end

    def send_heartbeat_acks?
      false
    end
  end
end
