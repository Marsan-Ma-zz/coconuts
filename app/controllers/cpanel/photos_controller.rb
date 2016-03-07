class Cpanel::PhotosController < Cpanel::ApplicationController

  def index
    @photos = Photo.all.desc(:updated_at).page(params[:page])
    @photo = Photo.new
  end

  def edit
    @photos = Photo.all.desc(:updated_at).page(params[:page])
    @photo = Photo.find(params[:id])
  end

  def create
    @photo = Photo.new(params[:photo])
    respond_to do |format|
      if @photo.save
        format.html { redirect_to cpanel_photos_path, notice: 'Photo was successfully created.' }
      else
        format.html { redirect_to cpanel_photos_path, notice: 'Photo creation failed, have you use duplicated slug?' }
      end
    end
  end

  def update
    @photo = Photo.find(params[:id])
    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to cpanel_photos_path, notice: 'Photo was successfully updated.' }
      else
        format.html { render action: "edit", notice: 'Photo edit railed, something wrong?' }
      end
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to cpanel_photos_path }
    end
  end

end
