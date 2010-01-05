require 'sinatra'
require 'active_record'
require 'haml'
require 'json'

class Whisper < ActiveRecord::Base
  def to_s
    "#{name} (#{version}) was pushed around #{created_at}"
  end
end

get '/' do
  @whispers = Whisperer.all
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
