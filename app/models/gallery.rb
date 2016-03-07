# coding: utf-8
class Gallery
  include Mongoid::BaseModel

  field :title
  field :image

  embedded_in :post
end

