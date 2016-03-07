# coding: utf-8
class PhotoUploader < BaseUploader
  # for post
  version :normal do
    process :resize_to_fit => [640, 640]
  end

  # for sidebar
  version :small, :from_version => :normal do
    process :resize_to_fit => [320, 320]
  end

  # for cpanel
  version :tiny, :from_version => :small do
    process :resize_to_fit => [80, 80]
  end

end
