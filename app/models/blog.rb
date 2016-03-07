# encoding: utf-8
class Blog
  include Mongoid::BaseModel

  paginates_per 10

  field :feed
  field :publish, :type => Boolean, :default => false   # article no need to re-auth before publish
  field :copyright, :type => Boolean, :default => false    # we have copyright for reposting this article
  field :active, :type => Boolean, :default => false    # activate this feed-parsing rule
  field :prefix                                         # feed title prefix
  field :comment                                        # inner comment about this blog
  field :script                                         # post-process this feed after scrape
  
  belongs_to :author, :class_name => "User", :inverse_of => :blog
  belongs_to :category

  index :feed => 1
  index :active => 1
  default_scope desc(:active)

  validates_presence_of :feed, :publish, :copyright, :active, :author

  #========================================
  #   connect with Wordpress MySQL
  #========================================
  def import_blog
    raw = Feedzirra::Feed.fetch_and_parse(self.feed)
    if (raw && raw.entries)
      raw.entries[0..4].each do |i|
        slug = slug_process(i.url.split('/').last.gsub(/\...*/, '') + "_" + self.author.name)
        post = Post.where(:slug => slug, :author_id => self.author_id).first
        post = entry2post(i, slug) if not post
      end
    end
  end

  def entry2post(i, slug)
    # content preprocess
    i.summary ||= i.content.gsub(/<(.*?)>/,'')[0..200] # prevent summary only blogger
    i.content ||= i.summary # prevent summary only blogger
    i.summary = process_post(i.summary.gsub(/<(.*?)>/,''))
    i.content = process_post(i.content)
    i.content = eval("i.content" + self.script)
    thumbnail = Nokogiri::HTML(i.content).css("img").first.attr("src") rescue Setting.post_dummy_thumbnail
    # blogger category as tag
    tag_ids = []
    i.categories.each do |i|
      tag = Tag.where(:slug => slug_process(i)).first
      tag = Tag.create(:name => i, :slug => i, :description => i) if not tag
      tag_ids << tag.id
    end
    # special author
    i.title = self.prefix + i.title if self.prefix
    # create post
    status = self.publish ? "published" : "pending"
    post = Post.create!(
      :author_id => self.author_id, :slug => slug, :title => i.title, :thumbnail => thumbnail,
      :excerpt => i.summary, :content => i.content, :status => status, :copyright => self.copyright,
      :published_at => Time.now, :category_ids => [self.category.id], :tag_ids => tag_ids, :original => i.url
    )
    # sync2wordpress
    post.post2wordpress if Rails.env == "production"
  end

  def htmlentitle(txt)
    coder = HTMLEntities.new(:html4)
    coder.encode(txt.gsub("'", ''))
  end

  def process_post(txt)
    txt = txt.gsub(/\[caption.*?\]/, '').gsub("\[\/caption\]", '').gsub(/width.*?>/, '>')
    txt = txt.gsub(/\[video=.*?v=(.*?)\]/, '<iframe src="http://www.youtube.com/embed/\1" frameborder="0" allowfullscreen></iframe>')
    txt = txt.gsub(/\[video=.*?vimeo\.com\/(.*?)\#at\=0\]/, '<iframe src="http://player.vimeo.com/video/\1"></iframe>')
    txt = txt.gsub(/&nbsp;|\r/, '').gsub(/\n\n+/, "\n\n")
    txt = txt.gsub(/\<noscript\>/, '').gsub("\<\/noscript\>", '')
    doc = Nokogiri.HTML(txt)
    doc.css('script').remove.xpath("//@*[starts-with(name(),'on')]").remove
    txt = doc.to_s
    txt = HTMLEntities.new(:html4).decode(txt)
  end

end
