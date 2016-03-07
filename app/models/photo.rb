class Photo
  include Mongoid::BaseModel

  paginates_per 10

  field :title
  field :slug
  field :description
  field :photo
  mount_uploader :photo, PhotoUploader

  index :title => 1

  validates_presence_of :slug, :photo
  validates_uniqueness_of  :slug
  before_save :slug_sanitize
end

