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

class MyApp < Sinatra::Base
  register Sinatra::Async

  set :server, 'thin'
  set :public_folder, File.dirname(__FILE__)

  get '/' do
    erb :index
  end

  get '/refresh' do
    @orchestra = Progenitor::Orchestra.instance
    @values = Statabase
    erb :refresh
  end

end

Progenitor::Orchestra.instance.on_play do |name, value|
  Statabase.set( name, value )
end

Progenitor::Orchestra.instance.on_register do |player, hears, plays|
  puts "Registration from: #{player.spalla_id}"
end

