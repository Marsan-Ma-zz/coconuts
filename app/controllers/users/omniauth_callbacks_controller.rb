# coding: utf-8
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(*providers)
    providers.each do |provider|
      class_eval %Q{
        def #{provider}
          if not current_user.blank?
            current_user.bind_service(env["omniauth.auth"])#Add an auth to existing
            redirect_to root_path, :notice => "Succesfully add #{provider.to_s.titleize} as authorization provider."
          else
            @user = User.find_or_create_for_#{provider}(env["omniauth.auth"])

            if @user.persisted?
              flash[:notice] = "Succesfully login with #{provider.to_s.titleize}."
              sign_in_and_redirect @user, :event => :authentication, :notice => "Login Success."
            else
              redirect_to root_path #new_user_registration_url
            end
          end
        end
      }
    end
  end

  provides_callback_for :twitter, :google, :facebook, :tqq2, :weibo, :douban

  # This is solution for existing account want bind Google login but current_user is always nil
  # https://github.com/intridea/omniauth/issues/185
  def handle_unverified_request
    true
  end


end
