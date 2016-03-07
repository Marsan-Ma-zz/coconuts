# coding: utf-8
class Cpanel::UsersController < Cpanel::ApplicationController
  before_filter :require_admin

  def index
    users = User.all
    users = users.where(:name => /#{params[:name]}/) if params[:name]
    @users = users.asc(:is_editor, :name).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        format.html { redirect_to cpanel_users_path, notice: "User \"#{@user.name}\" has been created." }
      else
        format.html { render action: "new", notice: "User \"#{@user.name}\" create failed, something wrong?" }
      end
    end
  end

  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to cpanel_users_path, notice: "User \"#{@user.name}\" has been updated." }
      else
        format.html { render action: "edit", notice: "User \"#{@user.name}\" update failed, something wrong?" }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    username = @user.name
    @user.destroy
    respond_to do |format|
      format.html { redirect_to cpanel_users_url, notice: "User \"#{username}\" has been deleted." }
    end
  end

end
