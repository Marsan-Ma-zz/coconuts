#encoding: utf-8  
require 'fileutils'
require 'open-uri'
require 'time'
require 'mysql2'

namespace :wordpress do
  desc "### Wordpress IO tasks ###"
  task :feed2beta => :environment do
    db = Mysql2::Client.new(:host => Setting.wp_sql, :username => Setting.wp_dbname, 
                            :database => Setting.wp_dbname, :password => Setting.wp_dbpassword)
    get_all_posts(db)
  end

  task :update2beta => :environment do
    db = Mysql2::Client.new(:host => Setting.wp_sql, :username => Setting.wp_dbname, 
                            :database => Setting.wp_dbname, :password => Setting.wp_dbpassword)
    get_all_posts(db, 30)
  end

  #========================================
  #   Main Function
  #========================================
  def get_all_posts(db, num=nil)
    if num # get recent posts number
      query = "SELECT * FROM `wp_posts` WHERE `post_status` NOT IN ('inherit', 'auto-draft', 'trash') AND `post_type` = 'post' ORDER BY `post_modified` DESC LIMIT #{num}"
    else  # get all posts
      query = "SELECT * FROM `wp_posts` WHERE `post_status` NOT IN ('inherit', 'auto-draft', 'trash') AND `post_type` = 'post' ORDER BY `post_modified`"
    end
    posts = db.query(query).to_a
    #puts "[Start] dump all posts..."
    posts.each do |post|
      post["post_name"] = slug_sanitize(post["post_name"])
      save_post_to_db(db, post) if Post.where(:slug => post["post_name"]).empty?
    end
    #puts "[Done] dump all posts."
  end

  #========================================
  #   Functions
  #========================================
  def get_author(db, id)
    query="select * from wp_users where `ID` = '#{id}'"
    user = db.query(query).to_a.first
  end
  
  def get_thumb(db, post_id)
    query="select * from wp_postmeta where `post_id` = '#{post_id}' and `meta_key` = 'thumbnail_url'"
    thumbnail = db.query(query).to_a.first["meta_value"] rescue Setting.post_dummy_thumbnail
  end
 
  def slug_sanitize(slug)
    slug = Pinyin.t(slug, '_').gsub(/[^\w]/, "_").downcase.gsub(/__*/, '_')[0..63]
  end
 
  def get_tags(db, id)
    query = "SELECT name FROM wp_terms INNER JOIN wp_term_taxonomy ON wp_term_taxonomy.term_id = wp_terms.term_id INNER JOIN wp_term_relationships ON wp_term_relationships.term_taxonomy_id = wp_term_taxonomy.term_taxonomy_id WHERE taxonomy = 'post_tag' AND object_id = #{id};"
    tags = db.query(query).to_a.map{|i| i["name"]}
  end
  
  def get_categories(db, id)
    query = "SELECT name FROM wp_terms INNER JOIN wp_term_taxonomy ON wp_term_taxonomy.term_id = wp_terms.term_id INNER JOIN wp_term_relationships ON wp_term_relationships.term_taxonomy_id = wp_term_taxonomy.term_taxonomy_id WHERE taxonomy = 'category' AND object_id = #{id};"
    cats = db.query(query).to_a.map{|i| i["name"]}
    cats -= ["未分類", "myfirefoxfeedburner"]
  end

  def get_cites(db, id)
    query = "SELECT * FROM `usn_content_support` WHERE `post_id` = #{id}"
    copyrights = db.query(query).to_a.map{|i| [i["source"], i["name"], i["url"]]}
  end

  def get_show_wiredtw(db, id)
    query = "SELECT * FROM `wp_postmeta` WHERE `post_id` = '#{id}' AND `meta_key` LIKE 'show_wired_tw'"
    hoembrew = (db.query(query).to_a.first["meta_value"] == "Yes") rescue false
  end

  def process_post(txt)
    txt = txt.gsub(/\[caption.*?\]/, '').gsub("\[\/caption\]", '').gsub(/width.*?>/, '>')
    txt = txt.gsub(/\[video=.*?v=(.*?)\]/, '<iframe src="http://www.youtube.com/embed/\1" frameborder="0" allowfullscreen></iframe>')
    txt = txt.gsub(/\[video=.*?vimeo\.com\/(.*?)\#at\=0\]/, '<iframe src="http://player.vimeo.com/video/\1"></iframe>')
    txt = txt.gsub(/\[video=(.*?)\]/, '<iframe src="\1"></iframe>')
    txt = txt.gsub(/&nbsp;|\r/, '').gsub(/\n\n+/, "\n\n")
  end

  def save_post_to_db(db, post)
    #time_start = Time.now
    author = get_author(db, post["post_author"].to_i)
    thumbnail = get_thumb(db, post["ID"])
    # create author
    user = User.where(:email => author['user_email']).first
    user = User.create(:name => author['user_nicename'], :email => author['user_email'], :password => "neowiredtw", :password_confirmation => "neowiredtw", :is_editor => false) if not user
    # create cats
    cat_ids = []
    categories = get_categories(db, post["ID"])
    categories.each do |i|
      cat = Category.where(:slug => slug_sanitize(i)).first
      cat = Category.create(:name => i, :slug => i, :description => i) if not cat
      cat_ids << cat.id
    end
    #copyright = categories.include?("myfirefoxfeedburner")
    copyright = get_show_wiredtw(db, post["ID"])
    # create tags
    tag_ids = []
    get_tags(db, post["ID"]).each do |i|
      tag = Tag.where(:slug => slug_sanitize(i)).first
      tag = Tag.create(:name => i, :slug => i, :description => i) if not tag
      tag_ids << tag.id
    end
    # post_status
    case post["post_status"]
      when "publish"
        status = "published"
      when "draft"
        status = "draft"
      when "future"
        status = "scheduled"
      when "pending"
        status = "pending"
      when "private"
        status = "consult"
      when "trash"
        status = "trashed"
      else
        status = "unknown"
    end
    # fail-save
    post["post_name"] = slug_sanitize(post["post_title"]) if (post["post_name"].size < 5)
    # time 
    post["post_modified_gmt"] += 8.hours if post["post_modified_gmt"]
    post["post_date_gmt"] += 8.hours if post["post_date_gmt"]
    # create post
    begin
      article = Post.where(:slug => slug_sanitize(post["post_name"])).first
      article = Post.create!(:author_id => user.id, :slug => post["post_name"], :title => post["post_title"], :thumbnail => thumbnail, 
        :excerpt => post['post_excerpt'], :content => post['post_content'], :status => status, :copyright => copyright,
        :created_at => post["post_date_gmt"], :updated_at => post["post_modified_gmt"], :published_at => post["post_date_gmt"],
        :category_ids => cat_ids, :tag_ids => tag_ids) if not article
      # create cites
      get_cites(db, post["ID"]).each do |i|
        cite = article.cites.where(:source => i[0], :name => i[1], :url => i[2]).first
        cite = article.cites.build(:source => i[0], :name => i[1], :url => i[2]).save if not cite
      end
      #puts "[Post]#{article.id}/#{article.slug}/#{article.title}/#{article.status}"
    rescue => e
      puts "[ERROR!]#{post.to_s}"
    end
  end

  def save_post_to_file(db, post, dump_path)
    author = get_author(db, post["post_author"].to_i)
    thumbnail = get_thumb(db, post["ID"])
    cats = get_categories(db, post["ID"]).to_s.gsub(/[\[\]\",]/, '')
    tags = get_tags(db, post["ID"]).to_s.gsub(/[\[\]\",]/, '')
    filename = dump_path + post["post_name"] + '.' + author['user_nicename']
    open(filename, 'w') do |f|
      f.puts post["post_title"]
      f.puts thumbnail
      f.puts post["post_name"]
      f.puts author['user_nicename']
      f.puts author['user_email']
      f.puts cats
      f.puts tags
      f.puts post['post_date']
      f.puts "---"
      f.puts post['post_excerpt']
      f.puts "---"
      f.puts post['post_content']
    end
  end
end

