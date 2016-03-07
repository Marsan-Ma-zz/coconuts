class Cpanel::FeedsController < Cpanel::ApplicationController
  before_filter :require_admin

  def index
    @feeds = Feed.all.desc(:updated_at).page(params[:page])
  end

  def new
    @feed = Feed.new
  end

  def edit
    @feed = Feed.find(params[:id])
  end

  def create
    @feed = Feed.new(params[:feed])
    respond_to do |format|
      if @feed.save
        format.html { redirect_to cpanel_feeds_path, notice: 'Feed was successfully created.' }
      else
        format.html { redirect_to cpanel_feeds_path, notice: 'Feed creation failed, have you use duplicated slug?' }
      end
    end
  end

  def update
    @feed = Feed.find(params[:id])
    respond_to do |format|
      if @feed.update_attributes(params[:feed])
        format.html { redirect_to cpanel_feeds_path, notice: 'Feed was successfully updated.' }
      else
        format.html { redirect_to cpanel_feeds_path, notice: 'Feed edit railed, something wrong?' }
      end
    end
  end

  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to cpanel_feeds_path }
    end
  end

end
