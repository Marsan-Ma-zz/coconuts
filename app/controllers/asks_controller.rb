class AsksController < ApplicationController
  layout "noframe"

  def index
    redirect_to new_ask_path
  end

  def show
    @ask = Ask.find(params[:id])
  end

  def new
    @ask = Ask.new
  end

  #def edit
  #  @asks = Ask.asc(:name).page(params[:page])
  #  @ask = Ask.find(params[:id])
  #end

  def create
    @ask = Ask.new(params[:ask])
    respond_to do |format|
      if @ask.save
        format.html { redirect_to ask_path(@ask), notice: 'Ask was successfully created.' }
      else
        format.html { redirect_to ask_path(@ask), notice: 'Ask submit failed, please try later.' }
      end
    end
  end

  #def update
  #  @ask = Ask.find(params[:id])
  #  respond_to do |format|
  #    if @ask.update_attributes(params[:ask])
  #      format.html { redirect_to edit_cpanel_ask_path(@ask), notice: 'Ask was successfully updated.' }
  #    else
  #      format.html { redirect_to edit_cpanel_ask_path(@ask), notice: 'Ask edit railed, something wrong?' }
  #    end
  #  end
  #end

  #def destroy
  #  @ask = Ask.find(params[:id])
  #  @ask.destroy
  #  respond_to do |format|
  #    format.html { redirect_to cpanel_asks_path }
  #  end
  #end

end
