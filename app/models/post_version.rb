# encoding: utf-8
class PostVersion
  include Mongoid::BaseModel

  field :title
  field :content
  field :diff, :default => ""

  index :title => 1
  belongs_to :post
  belongs_to :author, :class_name => "User"

end
