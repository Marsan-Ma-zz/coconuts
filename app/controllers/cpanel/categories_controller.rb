class Cpanel::CategoriesController < Cpanel::ApplicationController

  def index
    @categories = Category.asc(:name).page(params[:page])
    @category = Category.new
  end

  def edit
    @categories = Category.asc(:name).page(params[:page])
    @category = Category.find(params[:id])
  end

  def create
    @category = Category.new(params[:category])
    respond_to do |format|
      if @category.save
        format.html { redirect_to cpanel_categories_path, notice: 'Category was successfully created.' }
      else
        format.html { redirect_to cpanel_categories_path, notice: 'Category creation failed, something wrong?' }
      end
    end
  end

  def update
    @category = Category.find(params[:id])
    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to cpanel_categories_path, notice: 'Category was successfully updated.' }
      else
        format.html { redirect_to cpanel_categories_path, notice: 'Category update failed, something wrong?' }
      end
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    respond_to do |format|
      format.html { redirect_to cpanel_categories_path }
    end
  end
end
