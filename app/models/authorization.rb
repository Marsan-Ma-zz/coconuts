# coding: utf-8
class Authorization
  include Mongoid::BaseModel

  field :provider
  field :uid
  field :token
  field :secret

  belongs_to :user, :inverse_of => :authorizations
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
end

