class Cpanel::SidebarsController < Cpanel::ApplicationController

  def index
    @sidebars = Sidebar.asc(:name).page(params[:page])
    @sidebar = Sidebar.new
  end

  def edit
    @sidebars = Sidebar.asc(:name).page(params[:page])
    @sidebar = Sidebar.find(params[:id])
  end

  def create
    @sidebar = Sidebar.new(params[:sidebar])
    respond_to do |format|
      if @sidebar.save
        expire_fragment('wired_sidebar')
        format.html { redirect_to cpanel_sidebars_path, notice: 'Sidebar was successfully created.' }
      else
        format.html { redirect_to cpanel_sidebars_path, notice: 'Sidebar creation failed, have you use duplicated slug?' }
      end
    end
  end

  def update
    @sidebar = Sidebar.find(params[:id])
    respond_to do |format|
      if @sidebar.update_attributes(params[:sidebar])
        expire_fragment('wired_sidebar')
        format.html { redirect_to cpanel_sidebars_path, notice: 'Sidebar was successfully updated.' }
      else
        format.html { redirect_to cpanel_sidebars_path, notice: 'Sidebar edit railed, something wrong?' }
      end
    end
  end

  def destroy
    @sidebar = Sidebar.find(params[:id])
    @sidebar.destroy
    expire_fragment('wired_sidebar')
    respond_to do |format|
      format.html { redirect_to cpanel_sidebars_path }
    end
  end

end
