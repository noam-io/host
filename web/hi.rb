$: << File.expand_path(File.join(File.dirname(__FILE__), "..", "IDEO-Maestro/lib"))

require 'rubygems'
require 'eventmachine'
require 'sinatra/async'
require 'progenitor/maestro_server'

class SomeState
  @@values = {}

  def self.set(name, value)
    @@values[name] = value
  end

  def self.get(name)
    @@values[name] || 0
  end
end

class MyApp < Sinatra::Base
  register Sinatra::Async

  set :server, 'thin'

  get '/' do
    erb :index
  end

  get '/refresh' do
    @speed = SomeState.get( "speed" )
    @rpms = SomeState.get( "rpms" )
    erb :refresh
  end

end

server = Progenitor::MaestroServer.new(8833)
Progenitor::Orchestra.instance.on_play do |name, value|
  SomeState.set( name, value )
end

Progenitor::Orchestra.instance.on_register do |player, hears, plays|
  puts "Register #{player.spalla_id}"
end

EM::run do
  server.start
  MyApp.run!
end

