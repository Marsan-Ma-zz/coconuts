class Category
  include Mongoid::BaseModel

  paginates_per 10

  field :name
  field :slug
  field :description
  field :post_count, :type => Integer, :default => 0

  index :name => 1
  index :slug => 1

  ## DO NOT unmark following line, will impact pertormance !!
  ## See 'http://stackoverflow.com/questions/10809636/what-are-the-tradeoffs-of-using-mongoids-has-and-belongs-to-many-with-inverse-o'
  #has_and_belongs_to_many :posts, :class_name => "Post", :inverse_of => :categories

  validates_uniqueness_of  :slug
  before_save :slug_sanitize
end
