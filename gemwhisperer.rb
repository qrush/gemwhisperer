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
end

get '/' do
  @whispers = Whisper.all(:order => "created_at desc", :limit => 25)
  erb :index
end

post '/' do
  begin
    hash = JSON.parse(request.body.read)
    Whisper.create(:name    => hash["name"],
                   :version => hash["version"],
                   :url     => hash["project_uri"],
                   :info    => hash["info"])
  rescue Exception => ex
    # oops!
  end
end
