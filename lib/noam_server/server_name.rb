module NoamServer
  class ServerName
    attr_reader :raw_name, :broadcastable_name

    def initialize(name)
      @raw_name = name
      illegal_character = /[^\w \.\-]/
      max_size = 128
      @broadcastable_name = name.gsub(illegal_character, "-")[0...max_size]
    end

    def to_s
      self.broadcastable_name
    end
  end
end
