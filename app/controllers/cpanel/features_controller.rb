class Cpanel::FeaturesController < Cpanel::ApplicationController
  before_filter :require_admin

  def index
    @features = Feature.asc(:name).page(params[:page]).desc(:published_at)
    @feature = Feature.new
  end

  def edit
    @features = Feature.asc(:name).page(params[:page]).desc(:published_at)
    @feature = Feature.find(params[:id])
  end

  def create
    @feature = Feature.new(params[:feature])
    respond_to do |format|
      if @feature.save
        format.html { redirect_to cpanel_features_path, notice: 'Feature was successfully created.' }
      else
        format.html { redirect_to cpanel_features_path, notice: 'Feature creation failed, have you use duplicated slug?' }
      end
    end
  end

  def update
    @feature = Feature.find(params[:id])
    respond_to do |format|
      if @feature.update_attributes(params[:feature])
        format.html { redirect_to cpanel_features_path, notice: 'Feature was successfully updated.' }
      else
        format.html { redirect_to cpanel_features_path, notice: 'Feature edit railed, something wrong?' }
      end
    end
  end

  def destroy
    @feature = Feature.find(params[:id])
    @feature.destroy
    respond_to do |format|
      format.html { redirect_to cpanel_features_path }
    end
  end

end
