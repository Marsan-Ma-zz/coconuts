# coding: utf-8
class Cite
  include Mongoid::BaseModel

  field :source
  field :name
  field :url

  embedded_in :post
  #validates_presence_of :source, :name
end

