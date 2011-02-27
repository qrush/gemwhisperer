require 'sinatra'
require 'active_record'
require 'sqlite3'
require 'twitter'
require 'json'

if File.exist?('config/application.yml')
  config = YAML.load_file('config/application.yml')
  config.each{|k,v| ENV[k] = v }
end

Twitter.configure do |config|
  config.consumer_key       = ENV['CONSUMER_KEY']
  config.consumer_secret    = ENV['CONSUMER_SECRET']
  config.oauth_token        = ENV['REQUEST_TOKEN']
  config.oauth_token_secret = ENV['REQUEST_SECRET']
end

configure :development do
  ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => 'db/development.db'
  )
end

configure :production do
  creds = YAML.load_file('config/database.yml')['production']
  ActiveRecord::Base.establish_connection(creds)
end

def log(message)
  ActiveRecord::Base.logger.info message
end

class Whisper < ActiveRecord::Base
end

get '/' do
  @whispers = Whisper.order('created_at DESC').limit(25)
  erb :index
end

post '/hook' do
  data = request.body.read
  log "got webhook: #{data}"

  hash = JSON.parse(data)
  log "parsed json: #{hash.inspect}"

  whisper = Whisper.create(
    :name    => hash['name'],
    :version => hash['version'],
    :url     => hash['project_uri'],
    :info    => hash['info']
  )
  log "created whisper: #{whisper.inspect}"

  short_url = HTTParty.get("http://ln-s.net/home/api.jsp?url=#{Rack::Utils.escape(whisper.url)}").split.last
  log "shorted url: #{short_url}"

  response = Twitter.update("#{whisper.name} (#{whisper.version}): #{short_url}")
  log "TWEETED! #{response}"
end
