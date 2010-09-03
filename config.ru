require 'gemwhisperer'
require 'hoptoad_notifier'

HoptoadNotifier.configure do |config|
  config.api_key = ENV["HOPTOAD_KEY"]
end

use HoptoadNotifier::Rack
enable :raise_errors

run Sinatra::Application
