# encoding: utf-8
require 'carrierwave/processing/mini_magick'
class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :fog
  
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{model.class.to_s.underscore}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end
  
  # # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
    # "photo/#{version_name}.jpg"
  # end

  # # Add a white list of extensions which are allowed to be uploaded.
  # # For images you might use something like this:
  # def extension_white_list
    # %w(jpg jpeg gif png)
  # end
  
  def filename
    @name ||= "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
