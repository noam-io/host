require 'sinatra/async'
require 'noam/noam_server'
require 'noam/asset_deployer'
require 'helpers/refresh_helper.rb'


class Statabase
  @@values = {}
  @@timestamps = {}

  def self.set(name, value)
    @@values[name] = value
    @@timestamps[name] = DateTime.now
  end

  def self.get(name)
    @@values[name] || 0
  end

  def self.timestamp(name)
    @@timestamps[name]
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
$last_active_event = ""

class NoamApp < Sinatra::Base
  register Sinatra::Async

  set :server, 'thin'
  set :public_folder, File.dirname(__FILE__)
  set :port, 8081

  def self.asset_deployer=( value )
    @@asset_deployer = value
  end

  def self.broadcast_port=( value )
    @@broadcast_port = value
  end

  before do
    @broadcast_port = @@broadcast_port
  end

  get '/' do
    @orchestra = Noam::Orchestra.instance
    @values = Statabase
    erb :index
  end

  get '/refresh' do
    @orchestra = Noam::Orchestra.instance
    @values = Statabase
    erb :refresh
  end

  aget '/show-assets' do
    @spallas = Noam::Orchestra.instance.deployable_spalla_ids
    @folders = @@asset_deployer.available_assets
    body(erb :_deploy_assets, folders: @folders, spallas: @spallas)
  end

  aget '/arefresh' do
    Request.pile do
      @orchestra = Noam::Orchestra.instance
      @values = Statabase
      @last_active_id = $last_active_id
      @last_active_event = $last_active_event

      body(erb :refresh)
    end
  end

  post '/play-event' do
    Noam::Orchestra.instance.play( params[:name], params[:value], "Maestro Web" )
    body("ok")
  end

  post '/deploy-assets' do
    selected_spalla_players = Noam::Orchestra.instance.players_for(params[:spallas])
    EM.defer { @@asset_deployer.deploy( selected_spalla_players, params[:folders] ) }
    redirect '/'
  end
end

Noam::Orchestra.instance.on_play do |name, value, player|
  Statabase.set( name, value )
  $last_active_id = player.spalla_id if player
  $last_active_event = name
  Request.respond
end

Noam::Orchestra.instance.on_register do |player|
  puts "Registration from: #{player.spalla_id}"
  $last_active_id = player.spalla_id if player
  $last_active_event = ""
  Request.respond
end

Noam::Orchestra.instance.on_unregister do |player|
  puts "Spalla disconnected: #{player.spalla_id}" if player
  Request.respond
end

