require 'sinatra'
require 'active_record'
require 'haml'
require 'json'

class Whisper < ActiveRecord::Base
  def to_s
    "#{name} (#{version}) was pushed around #{created_at}"
  end
end

configure :development do
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                          :database => "development.db")
end

configure :production do
  #ActiveRecord::Base.establish_connection
end

get '/' do
  @whispers = Whisper.all
  haml :index
end

post '/' do
  begin
    hash = JSON.parse(request.body)
    Whisper.create(:name    => hash["name"],
                   :version => hash["version"])
  rescue Exception => ex
    # oops!
  end
end
