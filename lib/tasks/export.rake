#encoding: utf-8  

require 'sanitize'

namespace :export do
  task :json => :environment do
    mkdir_till(["dump", "posts"])
    posts = Post.where(:status => 'published')
    posts.each do |i|
      dump_post(i)
    end
  end

  task :txt => :environment do
    mkdir_till(["dump", "posts"])
    posts = Post.where(:status => 'published')
    posts.each do |i|
      dump_post_txt(i)
    end
  end

  task :corpus => :environment do
    posts = Post.where(:status => 'published')
    open("#{Rails.root}/dump/corpus.txt", 'w') do |f|
      posts.each do |i|
        f.puts i.title + "。" + Sanitize.clean(i.content.gsub("\n", ""))
      end
    end 
  end

  task :hash => :environment do
    posts = Post.where(:status => 'published')
    open("#{Rails.root}/dump/hash.txt", 'w') do |f|
      posts.each do |i|
        hash = Hash.new
        hash['title'] = i.title
        hash['image'] = i.thumbnail
        hash['text'] = Sanitize.clean(i.content.gsub("\n", ""))
        f.puts hash.to_json
      end
    end 
  end

  def dump_post_txt(i)
    t = Hash.new
    t["title"] = i.title
    t["thumbnail"] = i.thumbnail
    t["author"] = i.author.name
    t["categories"] = i.categories.map(&:name)
    t["tags"] = i.tags.map(&:name)
    t["status"] = i.status
    t["summary"] = i.excerpt
    t["content"] = i.content
    open("#{Rails.root}/dump/posts/#{i.slug}.json", 'w') do |f|
      f.puts t.to_json
    end 
    open("#{Rails.root}/dump/posts/#{i.slug}.txt", 'w') do |f|
      f.puts i.title
      f.puts i.thumbnail
      f.puts i.author.name
      f.puts i.status
      f.puts i.categories.map(&:name).join(',')
      f.puts i.tags.map(&:name).join(',')
      f.puts "---"
      f.puts i.excerpt
      f.puts "---"
      f.puts i.content
    end 
  end

  def dump_post(i)
    t = i.attributes.to_hash
    t["author"] = i.author.name
    t["author_email"] = i.author.email
    t["categories"] = i.categories.map(&:name)
    t["tags"] = i.tags.map(&:name)
    open("#{Rails.root}/dump/posts/#{i.slug}.post", 'w') do |f|
      f.puts t.to_json
    end 
  end

  def mkdir_till(dir)
    for i in 0..dir.size-1
      path = File.join(dir[0..i])
      Dir.mkdir(path) if not File.directory?(path)
    end
  end

end
