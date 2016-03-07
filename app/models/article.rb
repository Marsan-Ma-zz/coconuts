# Please note that the vanilla wp-json-api plugin does not support user authentication for create_post.
# Check out my fork for authentication support: https://github.com/Achillefs/wp-json-api
class Article
  API_URI = Setting.wp_api
  
  attr_accessor :title, :content, :categories, :tags, :type, :author, :passwd, :status, :slug, :thumbnail, :copyright, :excerpt, :cites
  
  def initialize(opts = {})
    # set all values if valid
    opts.each do |key,val|
      begin
        self.send(:"#{key}=",val)
      rescue NoMethodError => e
        raise ArgumentError("#{key} is not a valid article attribute")
      end
    end
    self.type = 'post' if self.type == nil
    self.status = 'pending' if self.status == nil
  end
  
  def publish!
    mysql = open_mysql(Setting.wp_sql, Setting.wp_username, Setting.wp_dbname, Setting.wp_dbpassword)
    # skip if post exists
    post = get_post_by_slug(mysql, self.slug)
    return if not post.empty?
    # Need to get a nonce token from WP in order to create a post
    nonce_response = JSON.parse(open(API_URI + "get_nonce/?controller=posts&method=create_post").read)
    if nonce_response['status'] == 'ok'
      nonce = nonce_response['nonce']
      url = URI.parse(API_URI + "posts/create_post")
      args = { 
        'nonce' => nonce, 'author' => self.author, 'user_password' => self.passwd, 
        'status' => 'publish', 'title' => self.title, 'content' => self.content,
        'categories' => self.categories.join(','), 'tags' => self.tags.join(','), 
        'type' => type, 'status' => status
      }
      resp, data = Net::HTTP.post_form(url, args)
      self.post_process(mysql)
      #puts resp.body
      #response = JSON.parse(resp)
      #if response['status'] == 'ok'
      #  puts response.inspect
      #else
      #  raise response['error'].to_s
      #end
    else
      raise nonce_response['error'].to_s
    end
  end

  def post_process(mysql)
    post = get_post_by_title(mysql, self.title)
    if not post.empty?
      post_id = post.first["ID"]
      # post slug
      cmd = "UPDATE `wp_posts` SET `post_name` = '#{self.slug}' WHERE `wp_posts`.`ID` =#{post_id} LIMIT 1"
      mysql.query(cmd)
      # post excerpt
      cmd = "UPDATE `wp_posts` SET `post_excerpt` = '#{self.excerpt}' WHERE `wp_posts`.`ID` =#{post_id} LIMIT 1"
      mysql.query(cmd)
      # save thumbnail
      insert_post_meta(mysql, post_id, "thumbnail_url", self.thumbnail)
      # post copyright
      insert_post_meta(mysql, post_id, "show_wired_tw", self.copyright)
      # post SEO
      insert_post_meta(mysql, post_id, "_aioseop_keywords", self.tags.join(","))
      insert_post_meta(mysql, post_id, "_aioseop_description", self.excerpt[0..200])
      insert_post_meta(mysql, post_id, "_aioseop_title", self.title)
      # post content source
      self.cites.each do |i|
        insert_content_source(mysql, post_id, i[0], i[1], i[2])
      end
    end
  end

  #============================================
  # Tasks
  #============================================
  private

  def open_mysql(host, user, dbname, password)
    wp_mysql = Mysql2::Client.new(:host => host, :username => user, :database => dbname, :password => password)
    wp_mysql
  end

  def htmlentitle(txt)
    coder = HTMLEntities.new(:html4)
    coder.encode(txt.gsub("'", ''))
  end

  def insert_post_meta(mysql, post_id, meta_key, meta_value)
    cmd = "INSERT INTO `wp_postmeta`(`meta_id`,`post_id`,`meta_key`,`meta_value`)"
    val = "VALUES (NULL, '#{post_id}', '#{meta_key}', '#{meta_value}')"
    mysql.query(cmd + ' ' + val)
  end

  def insert_content_source(mysql, post_id, source, name, url)
    cmd = "INSERT INTO `usn_content_support`(`cs_id`,`post_id`,`source`,`name`,`url`)"
    val = "VALUES (NULL, '#{post_id}', '#{source}', '#{name}', '#{url}')"
    mysql.query(cmd + ' ' + val)
  end

  def get_post_by_title(mysql, title, author_id=nil)
    #query="select * from wp_posts where `post_title` = '#{title}' and `post_type` = 'post'"
    #query="select * from wp_posts where `post_title` = '#{title}' and `post_type` = 'post' and `post_author` = '#{author_id}'" if author_id
    query="select * from wp_posts where `post_title` = '#{title}'"
    query="select * from wp_posts where `post_title` = '#{title}' and `post_author` = '#{author_id}'" if author_id
    #puts "[Query]" + query
    posts = mysql.query(query).to_a
  end


  def get_post_by_slug(mysql, slug, author_id=nil)
    query="select * from wp_posts where `post_name` = '#{slug}'"
    query="select * from wp_posts where `post_name` = '#{slug}' and `post_author` = '#{author_id}'" if author_id
    posts = mysql.query(query).to_a
  end
end
 
