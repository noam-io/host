module Noam
  class Player
    attr_accessor :last_activity
    attr_reader :spalla_id, :device_type, :system_version, :hears, :plays, :host, :port
    def device_key
      (@device_type || "").downcase
    end

    DeployableDevices = {
      "pi" => {:username => "pi", :deploy_path => '/home/pi/SpallaApp/qml', :sudo => true},
      "mac" => {:username => "progenitor", :deploy_path => '/Applications/SpallaApp.app/Contents/MacOS/qml', :sudo => false }
    }
    DeployableDevices.default = {:username => nil, :deploy_path => nil}

    def initialize(spalla_id, device_type, system_version, hears, plays, host, port)
      @spalla_id = spalla_id
      @device_type = device_type
      @system_version = system_version
      @hears = hears || []
      @plays = plays || []
      @host = host
      @port = port
    end

    def hears?(event)
      @hears.include?(event)
    end

    def plays?(event)
      @plays.include?(event)
    end

    def learn_to_play(event)
      @plays << event unless @plays.include?(event)
    end

    def deployable?
      DeployableDevices.has_key?(device_key)
    end

    def username
      DeployableDevices[device_key][:username]
    end

    def deploy_path
      DeployableDevices[device_key][:deploy_path]
    end

    def sudo
      DeployableDevices[device_key][:sudo]
    end
  end
end
