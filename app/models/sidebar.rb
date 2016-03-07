# coding: utf-8
class Sidebar
  include Mongoid::BaseModel

  field :order, :type => Integer, :default => 0
  field :title
  field :content
  field :comment
  field :active, :type => Boolean, :default => false

  default_scope asc(:order)
end

