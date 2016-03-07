# coding: utf-8
class AvatarUploader < BaseUploader
  version :big do
    process :resize_to_fill => [128, 128]
  end

  version :normal, :from_version => :big do
    process :resize_to_fill => [64, 64]
  end

  version :small, :from_version => :normal do
    process :resize_to_fill => [16, 16]
  end

  # def filename
    # if super.present?
      # "avatar/#{model.id}.#{file.extension.downcase}"
    # end
  # end
end
