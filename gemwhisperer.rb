require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'json'

configure :development do
  ActiveRecord::Base.establish_connection(:adapter  => "sqlite3",
                                          :database => "development.db")
end

configure :production do
  creds = YAML.load_file("config/database.yml")["production"]
  ActiveRecord::Base.establish_connection(creds)
end

class Whisper < ActiveRecord::Base
  def to_s
    "#{name} (#{version}) was pushed around #{created_at}"
  end
end

get '/' do
  @whispers = Whisper.all
  haml :index
end

post '/' do
  begin
    hash = JSON.parse(request.body)
    Whisper.create(:name    => hash["name"],
                   :version => hash["version"],
                   :url     => hash["project_uri"])
  rescue Exception => ex
    # oops!
  end
end
