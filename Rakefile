require "carrierwave"
require "carrierwave/orm/activerecord"
CarrierWave.configure do |config|
  config.root = File.dirname(__FILE__) + "/public"
end
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
#require 'carrierwave/orm/activerecord'
require 'require_all'
#require_all "uploader"
require_all 'model'
require_all 'module'
Dir.glob('lib/tasks/*.rake').each { |r| load r}
