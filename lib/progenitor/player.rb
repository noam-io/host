
module Progenitor
  class Player
    attr_reader :spalla_id, :device_type, :system_version, :hears, :plays, :host, :port
    def device_key
      @device_type.downcase
    end

    DeployableDevices = {"pi" => {:username => "pi", :deploy_path => '/home/pi/SpallaApp/qml'} }
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
  end
end
