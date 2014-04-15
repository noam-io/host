require 'em/pure_ruby'

module NoamServer
  class ConnectionPool

    def self.include?(connection)
      return false if connection.nil?
      !EventMachine::Reactor.instance.get_selectable(connection.signature).nil?
    end

  end
end
