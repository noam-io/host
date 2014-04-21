module Mocks
  class Reactor

    def initialize
      @selectables = {}
    end

    def connect_to(web_socket)
      @selectables[web_socket.signature] = web_socket
    end

    def get_selectable(web_socket_signature)
      @selectables[web_socket_signature]
    end

  end
end
