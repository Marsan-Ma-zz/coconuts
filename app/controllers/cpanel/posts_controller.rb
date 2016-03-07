# coding: utf-8
class Cpanel::PostsController < Cpanel::ApplicationController
  def index
    posts = Post.all
    posts = posts.where(:category_ids.in => [params[:category]]) if params[:category]
    posts = posts.where(:tag_ids.in => [params[:tag]]) if params[:tag]
    posts = posts.where(:title => /#{params[:contains]}/) if not params[:contains].blank?
    posts = posts.where(:status => params[:status]) if not params[:status].blank?
    posts = posts.where(:author_id => params[:author]) if (params[:author].to_i > 0)
    @posts = posts.desc(:published_at).page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  def show
    @post = Post.find(params[:id])
    @ver  = PostVersion.find(params[:version])
  end

  def new
    @post = Post.new
    cites = @post.cites.build
    galleries = @post.galleries.build
    @tags_sig, @tags_hot = get_tags_for_form
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @post = Post.find(params[:id])
    @post = recover_version(@post, params[:version]) if params[:version]
    @post.save
    @post.cites.where(:name => "").each do |i|
      i.destroy
    end
    @post.galleries.where(:image => "").each do |i|
      i.destroy
    end
    #cites = @post.cites.build
    @tags_sig, @tags_hot = get_tags_for_form
  end

  def create
    params[:post][:status] = params[:post][:status].downcase
    #params[:post][:published_at] += " #{params[:post][:"published_at_time"]}"
    params[:post][:tag_ids].concat(create_extra_tags(params[:tag_extra])).uniq
    @post = Post.new(params[:post])
    @post.modifier_id = current_user.id
    respond_to do |format|
      if @post.save
        expire_cache_for(@post)
        format.html { redirect_to edit_cpanel_post_path(@post), notice: "Post '#{@post.title}' was successfully created." }
        format.js { head :ok } 
        #format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new", notice: "Post '#{@post.title}' creation failed, something wrong?" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params[:post][:status] = params[:post][:status].downcase
    #params[:post][:published_at] += " #{params[:post][:"published_at(5i)"]}" #params[:post].parse_time_select! :published_at
    params[:post][:tag_ids].concat(create_extra_tags(params[:tag_extra])).uniq
    @post = Post.find(params[:id])
    @post.modifier_id = current_user.id
    respond_to do |format|
      if @post.update_attributes(params[:post])
        expire_cache_for(@post)
        format.html { redirect_to edit_cpanel_post_path(@post), notice: "Post '#{@post.title}' was successfully updated." }
        format.js { head :ok } 
        format.json { head :no_content }
      else
        format.html { render action: "edit", notice: "Post '#{@post.title}' update failed, something wrong?" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
    post_title = @post.title
    expire_cache_for(@post)
    @post.destroy
    respond_to do |format|
      format.html { redirect_to cpanel_posts_url, notice: "Post \"#{post_title}\" has been deleted." }
      format.json { head :no_content }
    end
  end

  def post2social
    self.post2social
  end

  private

  def get_editors(post)
    editors = User.where(:id.in => @post.editor_ids).only(:name).map(&:name).push(current_user.name)
  end
  
  def create_extra_tags(raw)
    extra_tag_ids = []
    raw.split("\s").each do |i|
      tag = Tag.where(:name => i).first
      tag = Tag.create(:name => i, :slug => i, :description => i) if not tag
      extra_tag_ids << tag.id
    end
    extra_tag_ids
  end
  
  def get_tags_for_form
    tag_ids_sig = Note.where(:key => "tags_sig").first.value
    tags_sig = Tag.where(:id.in => tag_ids_sig).only(:id, :name)
    tag_ids_hot = Note.where(:key => "tags_hot").first.value
    return tags_sig, tag_ids_hot
  end

  def expire_cache_for(post, expire_home=true)
    expire_fragment('wired_post_' + post.slug)
    expire_fragment('wired_home_cats') if expire_home
    expire_fragment('wired_home_banner') if expire_home
    clear_cache(:cache => "clear_feeds")
  end

  def recover_version(post, version_id)
    ver = PostVersion.find(version_id)
    post.title = ver.title
    post.content = ver.content
    post.author_id = ver.author_id
    post
  end

end
