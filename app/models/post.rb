# encoding: utf-8
class Post
  include Mongoid::BaseModel
  include Redis::Objects

  paginates_per 12

  field :format, :default => "normal" # layout: full, album, slider
  field :slug
  field :title
  field :thumbnail
  field :excerpt
  field :social_excerpt_common
  field :social_excerpt_geek
  field :content
  field :status, :default => "Draft"
  field :copyright, :type => Boolean, :default => false    # whether we have copyright to re-distribute
  field :published_at, type: DateTime, :default => Time.now
  field :original # blogger original link

  # counter
  counter :count_view

  # share ctrl
  field :post2social_done, :type => Boolean, :default => true
  field :post2social, :type => Boolean, :default => true
  field :post2china, :type => Boolean, :default => true
  
  field :facebook_wall_link
  field :twitter_wall_link
  field :gplus_wall_link
  
  index :slug => 1
  index :title => 1

  has_many :post_versions
  belongs_to :author, :class_name => "User", :inverse_of => :auth_posts
  belongs_to :modifier, :class_name => "User"
  embeds_many :cites #, :allow_destroy => true
  accepts_nested_attributes_for :cites
  embeds_many :galleries
  accepts_nested_attributes_for :galleries
  has_and_belongs_to_many :editors, :class_name => "User", :inverse_of => :edit_posts
  has_and_belongs_to_many :categories, :index => true
  has_and_belongs_to_many :tags, :index => true

  default_scope includes(:author, :categories, :tags)
  scope :published, where(:status => "published", :published_at.lt => Time.now).desc(:published_at)
  scope :publish_order, desc(:published_at)
 
  validates_presence_of :slug, :title #, :excerpt, :thumbnail, :content #, :author_id
  validates_uniqueness_of :slug

  before_save :author_as_editor, :slug_sanitize, :preprocess_post, :check_excerpt
  def author_as_editor  # for those import by script, will not through controller
    append_editor(self.author)
  end

  after_save :update_cat_tag_counter, :update_post_status_counter, :create_version #, :publish2wordpress
  def publish2wordpress
    self.post2wordpress if (self.status == "published")
  end

  def get_post_format
    # remove multi newline
    self.content = self.content.gsub(/&nbsp;|\r/, '').gsub(/\n\n+/, "\n\n")
    # move first img to banner
    if ["normal", "full"].include?(self.format)
      if not self.content[0..30].include?("iframe")
        self.content = self.content.sub(/<img(.*?)>/, '') 
      end
    end
    # wrap img with alt text
    doc = Nokogiri::HTML(self.content)
    doc.search("img").wrap("<div class='wrapimg'></div>")
    doc.search("img").each do |j|
      if not j.attr("alt").blank?
        alt = Nokogiri::XML::Node.new "p", doc
        alt.content = j.attr("alt")
        j.add_next_sibling(alt)
      end
    end

    self.content = doc.to_s.gsub(/\n\n+/, "<br /><br />").strip 
  end

  def update_cat_tag_counter
    self.categories.each do |i|
      i.post_count = Post.where(:category_ids.in => [i.id]).count
      i.save
    end
    self.tags.each do |i|
      i.post_count = Post.where(:tag_ids.in => [i.id]).count
      i.save
    end
    # update hot tags for speed-up cpanel form
    tag_ids = Tag.where(:post_count.gt => 3).only(:id, :name).asc(:name).map(&:id)
    create_or_update_note("tags_sig", tag_ids)
    hot_tag_names = Tag.desc(:post_count).only(&:id).limit(50).map(&:id).join(',')
    create_or_update_note("tags_hot", hot_tag_names)
  end

  def update_post_status_counter
    status = ['Published', 'Scheduled', 'Pending', 'Draft', 'External', 'Consult', 'Raw', 'Unknown', 'Trashed']
    status_count = Hash.new
    status_count["All"] = Post.count
    status.each do |i|
      status_count[i] = Post.where(:status => i.downcase).count
    end
    create_or_update_note("post_status_counter", status_count)
  end

  def create_version
    ver = PostVersion.new(:title => self.title, :content => self.content, :post_id => self.id, :author_id => self.modifier_id)
    if self.title_changed? or self.content_changed?
      last_ver = PostVersion.where(:post_id => self.id).desc(:updated_at).first
      if last_ver
        ver.diff = Diffy::Diff.new(last_ver.content, self.content, :context => 0).to_s(:html)
      else
        ver.diff = "Initial version."
      end
    else
      ver.diff = "Nothing changed."
    end
    ver.save
  end

  def check_excerpt
    if self.excerpt.size < 5
      self.excerpt = trim(self.content.gsub(/<(.*?)>/,''), 200)
    end
    self.excerpt = self.excerpt.gsub(/<(.*?)>/,'').strip
    self.social_excerpt_common ||= self.excerpt
    self.social_excerpt_geek ||= self.excerpt
    if self.thumbnail.blank?
      self.thumbnail = Setting.post_dummy_thumbnail
    end
  end

  def trim(txt, length)
    half = txt.gsub(/[\p{Han}]/, '').length
    full = txt.length - half
    trimtxt = (half/2 > full) ? txt[0..length-1] : txt[0..length/2-1]
    trimtxt += '...' if (trimtxt.length < txt.length)
    trimtxt
  end

  def get_cat
    cat = self.categories.blank? ? "未分類" : self.categories.first.name
  end

  def append_editor(user)
    self.push(:editor_ids, user.id) if not self.editor_ids.include?(user.id)
  end

  def self.find_by_slug(slug)
    where(:slug => slug).first
  end

  def preprocess_post
    txt = self.content
    txt = txt.gsub(/\[caption.*?\]/, '').gsub("\[\/caption\]", '').gsub(/width.*?>/, '>')
    txt = txt.gsub(/\[video=.*?v=(.*?)\]/, '<iframe src="http://www.youtube.com/embed/\1" frameborder="0" allowfullscreen></iframe>')
    txt = txt.gsub(/\[video=.*?vimeo\.com\/(.*?)\#at\=0\]/, '<iframe src="http://player.vimeo.com/video/\1"></iframe>')
    txt = txt.gsub(/\[video=(.*?)\]/, '<iframe src="\1"></iframe>')
    txt = txt.gsub(/&nbsp;|\r/, '').gsub(/\n\n+/, "\n\n")
    self.content = txt
  end

  def post2facebook
    ### facebook api "page": http://developers.facebook.com/docs/reference/api/page/
    ### ref: facebook debug => http://developers.facebook.com/tools/explorer/
    ### get fansite token through admin token : following steps
    token = Note.where(:key => "facebook_page_token").first.value # token updated from scheduled worker job 'update_facebook_bot_token'
    graph = Koala::Facebook::API.new(token)
    result = graph.put_connections("me","feed",:message=>self.excerpt,:picture=>self.thumbnail,:link=>"#{Setting.domain}/#{self.slug}")
    result = result["id"].split('_')
    self.update_attributes(:facebook_wall_link => "http://www.facebook.com/#{result[0]}/posts/#{result[1]}")
  end

  def post2twitter
    # limit msg size to 140 words
    link = Googl.shorten("http://#{Setting.domain}/posts/#{self.slug}").short_url
    msg = "[#{self.title}] #{self.excerpt}"
    if(msg.size > 110)
      diff = msg.size - 110
      msg = msg[0..-diff] + "...#{link}"
    else
      msg = msg + " #{link}"
    end
    # Post article to twitter (1. Twitter app-key initialize in devise.rb | 2. Twitter card added in header meta posts/_meta_twitter.html.erb')
    bot = Twitter::Client.new(
      :oauth_token => Note.where(:key => "twitter_page_token").first.value, # updated by scheduled worker
      :oauth_token_secret => Note.where(:key => "twitter_page_secret").first.value
    )
    Thread.new{bot.update(msg)}  # thread safe, from 'https://github.com/sferik/twitter'
  end

  def post2google(auth, msg)
    # [TODO] Google+ API is READ_ONLY currently ... finding work-around
  end


  def post2plurk(debug = false)
    #Build http request for login //api_key from http://cssula.nba.nctu.edu.tw/index.php/plurkproject/6-uncategorize/31-plurk-api-.html
    path = "/API/Users/login" + "?" + URI.encode_www_form({"api_key"=>"zKvwLFhOI0ePTDBSVpzZz9P6NeOoB9j3", "username"=>"wiredtw", "password"=>"neowiredtw", "no_data"=>"1"})
    req = Net::HTTP::Get.new(path)
    #Build HTTP connection
    http = Net::HTTP.new('www.plurk.com', 80)
    http.start
    response = http.request(req)
    http.finish
    #Remember the cookie given from server
    cookie = response['set-cookie']
    #Parse content to JSON
    if debug
      json = JSON.parse(response.body)
      puts json
    end
    #Build another http request for adding plurk
    req = Net::HTTP::Post.new("/API/Timeline/plurkAdd")
    msg = "#{self.title} http://#{Setting.domain}/posts/#{self.slug}"
    req.set_form_data({"api_key"=>"zKvwLFhOI0ePTDBSVpzZz9P6NeOoB9j3", "content"=> msg, "qualifier"=>":"})
    #This line is important for proving to server you've logged in
    req["Cookie"] = cookie
    #Build HTTP connection again
    http = Net::HTTP.new('www.plurk.com', 80)
    response = http.start{|connection|
      connection.request(req)
    }
    if debug
      json = JSON.parse(response.body)
      puts json
    end
  end

  def create_or_update_note(key, value)
    note = Note.where(:key => key).first
    if note
      note.update_attributes(:value => value)
    else
      note = Note.create(:key => key, :value => value)
    end
  end

  def post2wordpress
    a = Article.new(
      :author => self.author.name,
      :passwd => 'wired_blogger',
      :title => self.title,
      :content => self.content, #.split('<p>___</p>').first.gsub('<h3>', '<p><strong>').gsub('</h3>', '</strong></p>'),
      :categories => self.categories.map(&:name), #["Business"],
      :tags => self.tags.map(&:name),
      :slug => self.slug,
      :excerpt => self.excerpt,
      :thumbnail => self.thumbnail,
      :copyright => (self.copyright ? "Yes" : "No"),
      :cites => self.cites.map{|i| [i.source, i.name, i.url]},
      :status => "pending"
    )
    a.publish!
  end

end
