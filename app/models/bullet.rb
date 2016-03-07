# coding: utf-8
class Bullet
  include Mongoid::BaseModel

  paginates_per 12

  # main
  field :lang, type: String, :default => "zh"   #language
  field :title
  field :summary
  field :link
  field :source
  field :thumbnail
  field :published_at, type: DateTime, :default => Time.now
  field :relate_count, type: Integer, :default => 0
  field :follower_count, type: Integer, :default => 0

  # facebook curation score
  field :like_count, type: Integer, :default => 0
  field :share_count, type: Integer, :default => 0
  field :comment_count, type: Integer, :default => 0
  field :curate_score, type: Integer, :default => 0

  index :link => 1
  index :source => 1
  index :published_at => 1

  has_and_belongs_to_many :relates, :class_name => 'Bullet', :inverse_of => :relateds
  has_and_belongs_to_many :relateds, :class_name => 'Bullet', :inverse_of => :relates

  before_save :relation_count, :shorten_summary
  def relation_count
    self.relate_count = self.relate_ids.count
  end

  def get_thumb
    self.thumbnail.empty? ? Setting.bullet_dummy_thumbnail : self.thumbnail
  end

  def shorten_summary
    if not self.summary.empty?
      parts = self.summary.split(/[。！？：.!?:\n]/)
      boundary = (self.lang == "zh") ? 250 : 500
      for i in 0..parts.size-1
        if parts[0..i].join.size < boundary
          tail = parts[0..i].join.size + i + 1
        end
      end
      tail ||= self.summary.index(parts[0])
      short = self.summary[0..tail]
    end
  end

  def get_curate_count
    query = Fql.execute('SELECT like_count, share_count, comment_count, total_count from link_stat where url=' + "\"#{self.link}\"").first
    self.like_count = query['like_count'].to_i
    self.share_count = query['share_count'].to_i
    self.comment_count = query['comment_count'].to_i
    self.curate_score = 2*self.comment_count + 2*self.share_count + self.like_count
    self.save
  end

  def update_follower_count
    cnt = User.where(:collection_ids => self.id).count
    self.update_attributes(:follower_count => cnt)
  end
end

