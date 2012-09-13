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

      body(erb :refresh)
    end
  end

end

Progenitor::Orchestra.instance.on_play do |name, value|
  Statabase.set( name, value )
  Request.respond
end

Progenitor::Orchestra.instance.on_register do |player, hears, plays|
  puts "Registration from: #{player.spalla_id}"
  Request.respond
end

