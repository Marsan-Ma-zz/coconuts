class Note
  include Mongoid::BaseModel

  paginates_per 10

  field :key
  field :value
  field :description

  validates_presence_of :key #, :excerpt, :thumbnail, :content #, :author_id
  validates_uniqueness_of :key
  
end

