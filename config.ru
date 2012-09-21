#!/usr/bin/env ruby

$: << File.expand_path(File.join(File.dirname(__FILE__), "lib"))
$: << File.expand_path(File.join(File.dirname(__FILE__), "web"))

require 'eventmachine'
require 'sinatra/async'

require 'maestro_web'
require 'progenitor/udp_broadcaster'
require 'progenitor/asset_deployer'

PORT = 8833

PI_USERNAME = 'pi'
RSA_PRIVATE_KEY = File.expand_path(File.join(File.dirname(__FILE__), ".ssh", "maestro-key"))
ASSETS_LOCATION = File.expand_path(File.join(File.dirname(__FILE__), "sample-assets"))
PI_DEPLOY_DESTINATION = '/home/pi/SpallaApp/qml'

server = Progenitor::MaestroServer.new(PORT)
broadcaster = Progenitor::UdpBroadcaster.new(PORT)
deployer = Progenitor::AssetDeployer.new( PI_USERNAME, RSA_PRIVATE_KEY, ASSETS_LOCATION, PI_DEPLOY_DESTINATION )

EM::run do
  server.start
  MaestroApp.asset_deployer = deployer
  MaestroApp.run!

  EventMachine.add_periodic_timer(5) do
    broadcaster.go
  end
end

