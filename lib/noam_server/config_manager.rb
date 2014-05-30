#Copyright (c) 2014, IDEO

require 'config'
require 'fileutils'

#####
#
#  Class allows persistent storage in a heirarchical manner.
#


module NoamServer
  class JSONHash
    require 'json'
    def self.from(file)
      self.new.load(file)
    end
    def initialize(h={})
      @h=h
    end

    # Save this to disk, optionally specifying a new location
    def save(file=nil)
      @file = file if file
      FileUtils.mkdir_p(File.dirname(@file))
      File.open(@file,'w') do |f|
        f.write(JSON.pretty_generate(@h))
      end
      self
    end

    # Discard all changes to the hash and replace with the information on disk
    def reload(file=nil)
      @file = file if file
      @h = JSON.parse(IO.read(@file), :symbolize_names => true)
      self
    end

    # Let our internal hash handle most methods, returning what it likes
    def method_missing(*a,&b)
      @h.send(*a,&b)
    end

    # But these methods normally return a Hash, so we re-wrap them in our class
    %w[ invert merge select ].each do |m|
      class_eval <<-ENDMETHOD
        def #{m}(*a,&b)
          self.class.new @h.send(#{m.inspect},*a,&b)
        end
      ENDMETHOD
    end
  end

  class ConfigManager

    @@user_filename = ENV['HOME']+'/Documents/noam_settings.json'

    def self.instance
      @instance ||= self.new(CONFIG)
    end

    def initialize(defaults)
      @root_config = JSONHash.new(defaults)
      @_overwritten = JSONHash.new({})
      if File.exist?(@@user_filename)
        @_overwritten.reload(@@user_filename)
      end
      @_master = @root_config.clone
      @_master = @_master.merge(@_overwritten)
    end

    def save()
      @_overwritten.save(@@user_filename)
    end

    def method_missing(*a,&b)
      if a[0].to_s == "[]="
        @_overwritten.send(*a,&b)
        @_master.send(*a,&b)
        save()
      else
        @_master.send(*a,&b)
      end
    end

    def self.method_missing(*a,&b)
      self.instance.send(*a,&b)
    end

  end


end
