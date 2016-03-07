# encoding: utf-8
class Feed
  include Mongoid::BaseModel

  paginates_per 10

  field :title
  field :slug
  field :comment                                        # inner comment about this blog

  # subscribtion options 
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :authors, :class_name => "User"

  belongs_to :user
  validates_presence_of :title, :slug
  validates_uniqueness_of :slug
end
