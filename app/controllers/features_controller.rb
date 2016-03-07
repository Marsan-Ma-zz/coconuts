class FeaturesController < ApplicationController
  layout "full_custum"

  def index
    @mp_class = 'insider'
    if (current_user && current_user.admin?)
      @features = Feature.where(:public => true).desc(:published_at)
    else
      @features = Feature.where(:public => true, :published_at.lt => Time.now).desc(:published_at)
    end
    set_meta_tags :title => params[:controller], :description => "Wired Features", :keywords => params[:controller]
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @mp_class = 'posts'
    @mp_class_ext = 'feature'
    @feature = Feature.where(:slug => params[:id]).first
    post_ids = @feature.post_ids.split(' ')
    if (current_user && current_user.admin?)
      @posts = Post.where(:id.in => post_ids).asc(:slug)
    else
      @posts = Post.where(:id.in => post_ids, :published_at.lt => Time.now, :status => "published").asc(:slug)
    end
    feature_seo(@feature)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @category }
    end
  end

  private

  def feature_seo(feature)
    set_meta_tags :title => feature.title, :description => feature.excerpt
    set_meta_tags :twitter => {
      :card => "summary",
      :site => "@wired_tw",
      :creator => "@wired_tw", 
      :url => feature_url(feature.slug),
      :title => feature.title,
      :description => feature.excerpt,
      :image => feature.thumbnail
    }
    set_meta_tags :og => {
      :title    => feature.title,
      :type     => 'article',
      :url      => feature_url(feature.slug),
      :site_name => "Wired.TW",
      :description => feature.excerpt,
      :image    => feature.thumbnail,
    }
    set_meta_tags :fb => {
      :app_id   => "337912959569337",
      :image    => feature.thumbnail,
      :title    => feature.title,
      :type     => 'article',
      :url      => feature_url(feature.slug),
      :site_name => "Wired.TW",
      :description => feature.excerpt
    }
  end

end
