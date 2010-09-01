require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'json'
require 'twitter'

oauth  = Twitter::OAuth.new(ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'])
oauth.authorize_from_access(ENV['REQUEST_TOKEN'], ENV['REQUEST_SECRET'])
client = Twitter::Base.new(oauth)

configure :development do
  ActiveRecord::Base.establish_connection(:adapter  => "sqlite3",
                                          :database => "development.db")
end

configure :production do
  creds = YAML.load_file("config/database.yml")["production"]
  ActiveRecord::Base.establish_connection(creds)
end

class Whisper < ActiveRecord::Base
end

get '/' do
  @whispers = Whisper.all(:order => "created_at desc", :limit => 25)
  erb :index
end

post "/#{ENV['SECRET_ENDPOINT_URL']}" do
  hash    = JSON.parse(request.body.read)
  whisper = Whisper.create(:name    => hash["name"],
                           :version => hash["version"],
                           :url     => hash["project_uri"],
                           :info    => hash["info"])

  short_url = HTTParty.get("http://ln-s.net/home/api.jsp?url=#{whisper.url}").split.last
  client.update("#{whisper.name} (#{whisper.version}): #{short_url}")
end
