# coding: utf-8
class AboutsController < ApplicationController

  def index
  end

  def show
    if params[:id]
      @mp_class = params[:id]
      render "abouts/#{params[:id]}"
    else
      redirect_to :index
    end
  end

end
