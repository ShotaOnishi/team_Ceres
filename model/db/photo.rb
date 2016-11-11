require 'require_all'
require_all "uploader"

class Photo < ActiveRecord::Base
  require 'carrierwave'
  require 'carrierwave/orm/activerecord'
  mount_uploader :file, PhotosUploader
end