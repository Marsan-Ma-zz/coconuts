# encoding: utf-8
class FeedsController < ApplicationController
  before_filter :require_admin, :only => ["index", "destroy"]
  before_filter :require_login, :only => ["edit", "create", "update"]
  caches_action :show

  def edit
    @feed = Feed.where(:user_id => current_user.id).first
    @feed = Feed.new if not @feed
    respond_to do |format|
      format.html {}
    end
  end

  def show
    params[:slug] ||= "wiredtw"
    @feed = Feed.where(:slug => params[:slug]).first
    if @feed
      @posts = Post.published.where(:category_id.in => @feed.category_ids, :tag_id.in => @feed.tag_ids).limit(10)
      @posts = Post.published.limit(1) if @posts.empty?
      @timestamp  = @posts.empty? ? Time.now : @posts.first.updated_at
      respond_to do |format|
        format.atom { render :layout => false }
        format.rss { render :layout => false }
        format.json { render :json => post2json(@posts) }
      end
    else
      redirect_to root_path, :notice => "feed '#{params[:slug]}' does not exist.."
    end
  end

  def create
    @feed = Feed.new(params[:feed])
    @feed.user_id = current_user.id
    respond_to do |format|
      if @feed.save
        format.html { redirect_to edit_feed_path(@feed), notice: "Feed #{Setting.domain}/feed/#{@feed.slug} 產生成功！" }
      else
        format.html { redirect_to edit_feed_path(0), notice: '產生Feed失敗...網址和已存在的Feed重複囉！' }
      end
    end
  end

  def update
    @feed = Feed.where(:user_id => current_user.id).first
    respond_to do |format|
      if @feed.update_attributes(params[:feed])
        format.html { redirect_to edit_feed_path(@feed), notice: "Feed #{Setting.domain}/feed/#{@feed.slug} 更新成功！" }
      else
        format.html { redirect_to edit_feed_path(0), notice: '更新Feed失敗...網址和已存在的Feed重複囉！' }
      end
    end
  end

  private

  def post2json(raw)
    posts = Array.new
    raw.each do |i|
      j = Hash.new
      j["link"] = post_url(i.slug)
      j["title"] = i.title
      j["updated_at"] = i.updated_at
      j["author"] = i.author.name
      j["categories"] = i.categories.map(&:name)
      j["tags"] = i.tags.map(&:name)
      j["excerpt"] = i.excerpt
      j["content"] = i.content
      j["cites"] = i.cites.map{|i| [i.name, i.source, i.url]}.to_json
      posts << j
    end
    posts.to_json
  end
end
