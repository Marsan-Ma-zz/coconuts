# coding: utf-8
class Ask
  include Mongoid::BaseModel

  field :name
  field :description

  validates_presence_of :name, :description
end

