# coding: utf-8
class Cpanel::HomeController < Cpanel::ApplicationController
  def index
    if (params[:cache] && current_user.admin?)
      clear_cache(params) 
      redirect_to :back, :notice => "#{params[:cache]} cache cleared."
    end
  end
end
