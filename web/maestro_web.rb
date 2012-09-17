require 'sinatra/async'
require 'progenitor/maestro_server'


class Statabase
  @@values = {}

  def self.set(name, value)
    @@values[name] = value
  end

  def self.get(name)
    @@values[name] || 0
  end
end

class Request
  @@r = []

  def self.pile(&callback)
    @@r << callback
  end

  def self.respond
    @@r.each do |r|
      r.call
    end
    @@r.clear
  end
end

$last_active_id = ""

class MyApp < Sinatra::Base
  register Sinatra::Async

  set :server, 'thin'
  set :public_folder, File.dirname(__FILE__)

  get '/' do
    @orchestra = Progenitor::Orchestra.instance
    @values = Statabase
    erb :index
  end

  get '/refresh' do
    @orchestra = Progenitor::Orchestra.instance
    @values = Statabase
    erb :refresh
  end

  aget '/arefresh' do
    Request.pile do
      @orchestra = Progenitor::Orchestra.instance
      @values = Statabase
      @last_active_id = $last_active_id

      body(erb :refresh)
    end
  end

end

Progenitor::Orchestra.instance.on_play do |name, value, player_id|
  Statabase.set( name, value )
  $last_active_id = player_id
  Request.respond
end

Progenitor::Orchestra.instance.on_register do |player, hears, plays|
  puts "Registration from: #{player.spalla_id}"
  Request.respond
end

Progenitor::Orchestra.instance.on_unregister do |spalla_id|
  puts "Spalla disconnected: #{spalla_id}"
  Request.respond
end

