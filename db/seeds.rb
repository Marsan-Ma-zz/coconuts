# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.com/rails-environment-variables.html
#puts 'DEFAULT USERS'
#user = User.create!(:name => ENV['ADMIN_NAME'], :email => ENV['ADMIN_EMAIL'], 
#                    :password => ENV['ADMIN_PASSWORD'], :password_confirmation => ENV['ADMIN_PASSWORD'])
#puts 'user: ' << user.name

#===================================
#   Initialize categories & Tags
#===================================
cats = [["Technology", "tech"], ["Design", "design"], ["Business", "business"], ["Index", "index"], ["People", "people"], ["Gears", "gear"]]
tags = [["Google", "google"], ["Apple", "apple"], ["Amazon", "amazon"], ["Facebook", "facebook"], ["Tawiwan", "taiwan"]]
cats.each do |i|
  Category.create(:name => i[0], :slug => i[1], :description => "描述")
end
tags.each do |i|
  Tag.create(:name => i[0], :slug => i[1], :description => "描述")
end

#===================================
#   Import Posts & Authors
#===================================
def file2str(filename)
  data = ""
  f = File.open(filename, "r")
  f.each_line do |line|
    data += line
  end
  data
end

def process_post(txt)
  txt = txt.gsub(/\[caption.*?\]/, '').gsub("\[\/caption\]", '').gsub(/width.*?>/, '>')
  txt = txt.gsub(/\[video=.*?v=(.*?)\]/, '<iframe src="http://www.youtube.com/embed/\1" frameborder="0" allowfullscreen></iframe>')
  txt = txt.gsub(/\[video=.*?vimeo\.com\/(.*?)\#at\=0\]/, '<iframe src="http://player.vimeo.com/video/\1"></iframe>')
end

Dir.glob("./db/posts/*").each do |file|
  raw = file2str(file).lines.to_a.map{|s| s.gsub(/[\r\n]/, '')}
  t = raw[5].split(/[- :]/).map{|s| s.to_i}
  time = Time.new(t[0], t[1], t[2], t[3], t[4], t[5])
  author = User.where(:name => raw[3], :email => raw[4]).first
  author = User.create(:name => raw[3], :email => raw[4], :password => "neowiredtw", :password_confirmation => "neowiredtw", :is_editor => true) if not author
  content = process_post(raw[9..-1].join)
  post = Post.where(:author_id => author.id, :title => raw[0], :thumbnail => raw[1], :slug => raw[2]).first
  post = Post.create(:author_id => author.id, :title => raw[0], :thumbnail => raw[1], :slug => raw[2], 
          :excerpt => raw[7], :content => content, :created_at => time, :updated_at => time, :status => "Published", :published_at => time,
          :category_id => (1 + (rand*5).round), :tag_ids => [1+(rand*4).round]
         ) if not post
end

#===================================
#   Initialize feeds IO
#===================================
Blog.create(:feed => "http://mrjamie.cc/feed", :publish => true, :copyright => true, :active => false, :comment => "AppWorks Mr.Jamie", 
      :script => ".split('<h3 class=\"related_post_title\">').first.gsub('<h3>', '<p><strong>').gsub('</h3>', '</strong></p>')", 
      :author_id => 39, :category_id => 3)
Feed.create(:title => "All", :slug => "wiredtw", :comment => "all accessible", :category_ids => [1,2,3,4,5,6,nil], :tag_ids => [1,2,3,4,5,nil])
Feed.create(:title => "Firefox", :slug => "firefox", :comment => "for firefox", :category_ids => [5, 6, 1, nil], :tag_ids => [3, 5, 2, nil])

#===================================
#   Initialize Site-Note
#===================================
Note.create(:key => "twitter_page_token", :value => "")
Note.create(:key => "twitter_page_secret", :value => "")
Note.create(:key => "facebook_bot_token", :value => "")
Note.create(:key => "facebook_page_token", :value => "")


