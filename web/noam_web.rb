require 'sinatra/async'
require 'noam_server/noam_server'
require 'noam_server/asset_deployer'
require 'noam_server/config'
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

# Store value and time of last message per player for web interface
NoamServer::Orchestra.instance.on_play do |name, value, player|
  Statabase.set( name, value )
  $last_active_id = player.spalla_id if player
  $last_active_event = name
  Request.enqueue_response
end

NoamServer::Orchestra.instance.on_register do |player|
  $last_active_id = player.spalla_id if player
  $last_active_event = ""
  Request.enqueue_response
end

NoamServer::Orchestra.instance.on_unregister do |player|
  Request.enqueue_response
end

class Request
  @@r = Queue.new
  @@pending_responses = false

  def self.pile(&callback)
    @@r << callback
  end

  def self.enqueue_response
    @@pending_responses = true
  end

  def self.pending_responses?
    @@pending_responses
  end

  def self.respond
    while !@@r.empty?
      r = @@r.pop
      r.call
    end
    @@pending_responses = false
  end
end

$last_active_id = ""
$last_active_event = ""

class NoamApp < Sinatra::Base
  register Sinatra::Async

  set :server, 'thin'
  set :public_folder, File.dirname(__FILE__)
  set :port, CONFIG[:web_server_port]

  def self.asset_deployer=( value )
    @@asset_deployer = value
  end

  def self.broadcast_port=( value )
    @@broadcast_port = value
  end

  def self.run!
    EM::add_periodic_timer(1) do
      if Request.pending_responses?
        Request.respond
      end
    end

    super
  end

  before do
    @broadcast_port = @@broadcast_port
  end

  get '/' do
    @orchestra = NoamServer::Orchestra.instance
    @values = Statabase
    erb :index
  end

  get '/refresh' do
    @orchestra = NoamServer::Orchestra.instance
    @values = Statabase
    erb :refresh
  end

  aget '/show-assets' do
    @spallas = NoamServer::Orchestra.instance.deployable_spalla_ids
    @folders = @@asset_deployer.available_assets
    body(erb :_deploy_assets, folders: @folders, spallas: @spallas)
  end

  aget '/arefresh' do
    Request.pile do
      @orchestra = NoamServer::Orchestra.instance
      @values = Statabase
      @last_active_id = $last_active_id
      @last_active_event = $last_active_event

      body(erb :refresh)
    end
  end

  post '/play-event' do
    NoamServer::Orchestra.instance.play( params[:name], params[:value], "Maestro Web" )
    body("ok")
  end

  post '/stop-server' do
    CONFIG[:logger].info "Stopping server from web interface..."
    EM.next_tick do
      EM.stop
    end
    body("ok")
  end

  post '/deploy-assets' do
    selected_spalla_players = NoamServer::Orchestra.instance.players_for(params[:spallas])
    EM.defer { @@asset_deployer.deploy( selected_spalla_players, params[:folders] ) }
    redirect '/'
  end
end
