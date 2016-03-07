# coding: utf-8
class PostsController < ApplicationController
  layout :resolve_layout

  def index
    @mp_class = "category"  # for css
    posts = Post.published
    if params[:category]
      cat = Category.where(:slug => params[:category]).first
      posts = posts.where(:category_ids.in => [cat.id]) rescue Post.where(:id => 0)
      @title = "分類為#{cat.name}的文章" rescue "目前尚無被分類為#{params[:category]}的文章..."
      @branch = ["category", params[:category]]
      set_meta_tags :title => params[:category], :description => "Wired Articles about #{params[:category]}", :keywords => params[:category]
    elsif params[:tag]
      tag = Tag.where(:slug => params[:tag]).first
      case params[:tag]
        when "opinion"
          catid = Category.where(:slug => "people").first.id
          x_tagid = Tag.where(:slug => "innovation").first.id
          posts = posts.where(:category_ids.in => [catid]).not_in(:tag_ids => [x_tagid])
        when "innovation"
          catid = Category.where(:slug => "people").first.id
          x_tagid = Tag.where(:slug => "opinion").first.id
          posts = posts.where(:category_ids.in => [catid]).not_in(:tag_ids => [x_tagid])
        when "global_design"
          catid = Category.where(:slug => "design").first.id
          x_tagid = Tag.where(:slug => "local_design").first.id
          posts = posts.where(:category_ids.in => [catid]).not_in(:tag_ids => [x_tagid])
        else
          posts = posts.where(:tag_ids.in => [tag.id]) rescue Post.where(:id => 0)
      end
      @title = "關鍵字為#{tag.name}的文章" rescue "目前尚無關鍵字為#{params[:tag]}的文章..."
      @branch = ["tag", params[:tag]]
      set_meta_tags :title => params[:tag], :description => "Wired Articles about #{params[:tag]}", :keywords => params[:tag]
    elsif params[:user]
      user = User.find(params[:user])
      posts = posts.where(:author_id => user.id)
      @title = "#{user.name}的文章"
      @branch = ["user", params[:user]]
    else
      @title = "全部文章"
      @branch = ["all", ""]
      set_meta_tags :title => params[:controller], :description => "Wired Articles", :keywords => "Wired, posts, articles, all"
    end
    @posts = posts.page(params[:page])
    @eop = params[:page] ? (params[:page].to_i > @posts.num_pages) : false
    respond_to do |format|
      format.html # index.html.erb
      format.js   # for infinite-scroll
      #format.json { render json: @posts }
    end
  end

  def show
    params[:id] = slug_sanitize(params[:id])
    @post = Post.find_by_slug(params[:id])
    @post = Post.find(params[:id]) if not @post
    @post.count_view.incr
    @mp_class = (@post.format == "full") ? "posts full" : "posts"  # for css
    post_seo(@post)
    respond_to do |format|
      format.html # show.html.erb
      #format.json { render json: @post }
    end
  end

  private
    
  def resolve_layout
    case action_name
    when "index"
      "no_sidebar"
    when "show"
      "full_custum"
    else
      "application"
    end
  end

  def slug_sanitize(slug)
    slug = Pinyin.t(slug, '_').gsub(/[^\w]/, "_").downcase.gsub(/__*/, '_')[0..127]
  end

  def post_seo(post)
    keywords = post.categories.map(&:name).join(',') + ',' + post.tags.map(&:name).join(',')
    set_meta_tags :title => post.title, :description => post.excerpt, :keywords => keywords
    set_meta_tags :twitter => {
      :card => "summary",
      :site => "@wired_tw",
      :creator => "@wired_tw", 
      :url => post_url(post.slug),
      :title => post.title,
      :description => post.excerpt,
      :image => post.thumbnail
    }
    set_meta_tags :og => {
      :title    => post.title,
      :type     => 'article',
      :url      => post_url(post.slug),
      :site_name => "Wired.TW",
      :description => post.excerpt,
      :image    => post.thumbnail,
    }
    set_meta_tags :fb => {
      :app_id   => "337912959569337",
      :image    => post.thumbnail,
      :title    => post.title,
      :type     => 'article',
      :url      => post_url(post.slug),
      :site_name => "Wired.TW",
      :description => post.excerpt
    }
  end

end
