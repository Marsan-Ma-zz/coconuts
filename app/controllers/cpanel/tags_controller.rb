class Cpanel::TagsController < Cpanel::ApplicationController

  def index
    @tags = Tag.asc(:name).page(params[:page])
    @tag = Tag.new
  end

  def edit
    @tags = Tag.asc(:name).page(params[:page])
    @tag = Tag.find(params[:id])
  end

  def create
    @tag = Tag.new(params[:tag])
    respond_to do |format|
      if @tag.save
        format.html { redirect_to cpanel_tags_path, notice: 'Tag was successfully created.' }
      else
        format.html { redirect_to cpanel_tags_path, notice: 'Tag creation failed, have you use duplicated slug?' }
      end
    end
  end

  def update
    @tag = Tag.find(params[:id])
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        format.html { redirect_to cpanel_tags_path, notice: 'Tag was successfully updated.' }
      else
        format.html { redirect_to cpanel_tags_path, notice: 'Tag edit railed, something wrong?' }
      end
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to cpanel_tags_path }
    end
  end

end
