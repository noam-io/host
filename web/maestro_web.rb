require 'sinatra/async'
require 'progenitor/maestro_server'
require 'progenitor/asset_deployer'


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
$last_active_event = ""

class MaestroApp < Sinatra::Base
  register Sinatra::Async

  set :server, 'thin'
  set :public_folder, File.dirname(__FILE__)
  set :port, 8081

  def self.asset_deployer=( value )
    @@asset_deployer = value
  end

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

  aget '/show-assets' do
    @spallas = Progenitor::Orchestra.instance.deployable_spalla_ids
    @folders = @@asset_deployer.available_assets
    body(erb :_deploy_assets, folders: @folders, spallas: @spallas)
  end

  aget '/arefresh' do
    Request.pile do
      @orchestra = Progenitor::Orchestra.instance
      @values = Statabase
      @last_active_id = $last_active_id
      @last_active_event = $last_active_event

      body(erb :refresh)
    end
  end

  post '/play-event' do
    Progenitor::Orchestra.instance.play( params[:name], params[:value], "Maestro Web" )
    body("ok")
  end

  post '/deploy-assets' do
    selected_spalla_ips = Progenitor::Orchestra.instance.ips_for(params[:spallas])
    EM.defer { @@asset_deployer.deploy( selected_spalla_ips, params[:folders] ) }
    redirect '/'
  end
end

Progenitor::Orchestra.instance.on_play do |name, value, player|
  Statabase.set( name, value )
  $last_active_id = player.spalla_id if player
  $last_active_event = name
  Request.respond
end

Progenitor::Orchestra.instance.on_register do |player|
  puts "Registration from: #{player.spalla_id}"
  $last_active_id = player.spalla_id if player
  $last_active_event = ""
  Request.respond
end

Progenitor::Orchestra.instance.on_unregister do |player|
  puts "Spalla disconnected: #{player.spalla_id}" if player
  Request.respond
end

