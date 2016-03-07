class Feature
  include Mongoid::BaseModel

  paginates_per 10

  field :title
  field :slug
  field :excerpt
  field :thumbnail
  field :published_at, type: DateTime, :default => Time.now
  field :post_ids
  field :public, :type => Boolean, :default => true

  default_scope asc(:name)
  scope :published, where(:public => true, :published_at.lt => Time.now)
  validates_presence_of :slug, :title #, :excerpt, :thumbnail, :content #, :author_id
  validates_uniqueness_of :slug

end

