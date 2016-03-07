# coding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_user_i18n

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => "權限不足..."
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_referrer_or_default(default)
    redirect_to(request.referrer || default)
  end

  def set_user_i18n
    if user_signed_in?
      # Use user setting if login
      Time.zone = current_user.timezone if current_user.timezone
      I18n.locale = current_user.language if current_user.language
    else
      set_language
      set_timezone
    end
  end

  def require_login
    if current_user.blank?
      respond_to do |format|
        format.html  {
          redirect_to root_path, notice: "You need to login first !"
        }
      end
    end
  end

  def require_editor
    if not current_user.editor?
      redirect_to root_path, notice: "You must have editor right!"
    end
  end

  def require_admin
    if (current_user.blank? || !Setting.admin_emails.include?(current_user.email))
      redirect_to root_path, notice: "You must be administrator!"
    end
  end

  private

  def find_language
    available = %w{zh-TW zh-CN en ja ko fr de nl ru}
    request.compatible_language_from(available)
  end

  def set_language
    if cookies[:language]
      I18n.locale = cookies[:language]
    else
      I18n.locale = find_language # Detect locale from browser
      cookies[:language] = I18n.locale
    end
  end

  def set_timezone
    tz = cookies[:timezone]
    Time.zone = ActiveSupport::TimeZone[cookies[:timezone].to_i] unless tz.nil?
    # puts "[LOG]" + cookies[:timezone].to_s + "set_timezone = " + Time.zone.to_s
  end

end
