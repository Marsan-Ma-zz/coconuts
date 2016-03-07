class InsidersController < ApplicationController
  layout "no_sidebar"
  
  def index
    @mp_class = "insider"
    @insiders = User.where(:is_insider => true).desc(:order)
    set_meta_tags :title => params[:controller], :description => "Wired Insiders", :keywords => params[:controller]
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
