# encoding: utf-8
class IframesController < ApplicationController
  layout "noframe"

  # demo all iframes
  def index
    @posts = Post.desc(:updated_at).limit(5) if (params[:id] == "news")
  end

  def show
    case params[:id]
      when 'suggestions'
        @posts = Post.desc(:updated_at).limit(5)
      when 'marquee'
        @posts = Post.desc(:updated_at).limit(5)
      when 'features'
        @features = Feature.published
      when 'feature'
        @feature = Feature.where(:slug => params[:fid]).first
        post_ids = @feature.post_ids.split(' ')
        @posts = Post.published.where(:id.in => post_ids)
    end
    if params[:id] == "full"
      render "iframes/#{params[:id]}", :layout => "empty"
    elsif params[:id]  
      render "iframes/#{params[:id]}"
    else
      redirect_to root_path
    end
  end

end
