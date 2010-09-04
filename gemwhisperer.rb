require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'json'
require 'twitter'

oauth  = Twitter::OAuth.new(ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'])
oauth.authorize_from_access(ENV['REQUEST_TOKEN'], ENV['REQUEST_SECRET'])
client = Twitter::Base.new(oauth)
MAX_TWEET_LENGTH = 140

configure :development do
  ActiveRecord::Base.establish_connection(:adapter  => "sqlite3",
                                          :database => "development.db")
end

configure :production do
  creds = YAML.load_file("config/database.yml")["production"]
  ActiveRecord::Base.establish_connection(creds)
end

def log(message)
  ActiveRecord::Base.logger.info message
end

class Whisper < ActiveRecord::Base
end

get '/' do
  @whispers = Whisper.all(:order => "created_at desc", :limit => 25)
  erb :index
end

post "/#{ENV['SECRET_ENDPOINT_URL']}" do
  data = request.body.read
  log "got webhook: #{data}"

  hash = JSON.parse(data)
  log "parsed json: #{hash.inspect}"

  whisper = Whisper.create(:name    => hash["name"],
                           :version => hash["version"],
                           :url     => hash["project_uri"],
                           :info    => hash["info"])
  log "created whisper: #{whisper.inspect}"

  short_url = HTTParty.get("http://ln-s.net/home/api.jsp?url=#{Rack::Utils.escape(whisper.url)}").split.last
  log "shorted url: #{short_url}"

  tweet = "#{whisper.name} (#{whisper.version}): #{whisper.info} #{short_url}"
  if tweet.size > MAX_TWEET_LENGTH
    ellipses = '... '
    chars_over = tweet.size - MAX_TWEET_LENGTH + ellipses.length
    tweet = "#{whisper.name} (#{whisper.version}): #{whisper.info[0..-chars_over]}#{ellipses}#{short_url}"    
  end

  response = client.update(tweet)
  log "TWEETED! #{response}"
end
