class Cpanel::BlogsController < Cpanel::ApplicationController
  before_filter :require_admin

  def index
    @blogs = Blog.all.desc(:updated_at).page(params[:page])
    @blog = Blog.new
  end

  def edit
    @blogs = Blog.all.desc(:updated_at).page(params[:page])
    @blog = Blog.find(params[:id])
  end

  def launch
    #BlogsWorker.perform_async
    if params[:feed] 
      blogs = Blog.where(:feed => params[:feed])
    else
      blogs = Blog.where(:active => true)
    end
    blogs.each do |i|
      i.import_blog
    end
    redirect_to cpanel_blogs_path, notice: 'Start background job for importing blogs ... wait awhile to check posts.'
  end

  def create
    @blog = Blog.new(params[:blog])
    respond_to do |format|
      if @blog.save
        format.html { redirect_to cpanel_blogs_path, notice: 'Blog was successfully created.' }
      else
        format.html { redirect_to cpanel_blogs_path, notice: 'Blog creation failed, have you use duplicated slug?' }
      end
    end
  end

  def update
    @blog = Blog.find(params[:id])
    respond_to do |format|
      if @blog.update_attributes(params[:blog])
        format.html { redirect_to cpanel_blogs_path, notice: 'Blog was successfully updated.' }
      else
        format.html { redirect_to cpanel_blogs_path, notice: 'Blog edit failed, something wrong?' }
      end
    end
  end

  def destroy
    @blog = Blog.find(params[:id])
    @blog.destroy
    respond_to do |format|
      format.html { redirect_to cpanel_blogs_path }
    end
  end

end
