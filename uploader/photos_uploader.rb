class PhotosUploader < CarrierWave::Uploader::Base
    require "carrierwave"
    require "cloudinary"
    require 'carrierwave/orm/activerecord'
    include CarrierWave::MiniMagick
    include Cloudinary::CarrierWave

    #storage :file

    #サムネイル画像の生成
    # version :thumb do
    #     process :resize_to_fill => [200, 200]
    # end
    process :convert => 'png'
    process :tags => ['picture']

    version :standard do
        process :resize_to_fit => [800,800]
    end

    version :thumbnail do
        process :resize_to_fit => [240, 240]
    end

    def public_id
        return model.id
    end


    #縮小画像の生成
    # version :small do
    #     process :resize_to_limit => [900, 900]
    # end
    #ファイル名を一意に ex.b52d259b93.jpg
   #  def filename
   #     "#{secure_token(10)}.#{file.extension}" if original_filename.present?
   # end

end