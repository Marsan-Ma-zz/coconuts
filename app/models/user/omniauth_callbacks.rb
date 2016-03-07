# coding: utf-8
class User
  # Facebook user api : http://developers.facebook.com/docs/reference/api/user/
  # Facebook graph explorer : http://developers.facebook.com/tools/explorer/
  module OmniauthCallbacks
    ["google","twitter","facebook","tqq2","weibo","douban"].each do |provider|
      define_method "find_or_create_for_#{provider}" do |response|
        # puts response
        uid = response["uid"]
        data = response["info"]
        token = response["credentials"]["token"]
        secret = response["credentials"]["secret"]

        # 1. Existing user
        auth = Authorization.where(:provider => provider, "uid" => uid).first
        if (auth && auth.user)
          user = auth.user
          puts "[Exist-Login]#{token}/#{secret}"
          if user.avatar.blank?
            user.remote_avatar_url = find_avatar(provider, response)
            user.order += 1
            user.save
          end
          auth.update_attributes(:token => token, :secret => secret)
          auth.save
          return user
        # 2. Existing user login by different social network account
        elsif user = User.find_by_email(data["email"])
          puts "[Diff-Login]#{token}/#{secret}"
          Authorization.create(:provider => provider, :uid => uid, :token => token, :secret => secret, :user_id => user.id)
          user.remote_avatar_url = find_avatar(provider, response)
          user.save
          return user
        # 3. New user
        else
          puts "[New-Login]#{token}/#{secret}"
          user = User.new_from_provider_data(provider, uid, data)
          user.remote_avatar_url = find_avatar(provider, response)
          if user.save(:validate => false)
            Rails.logger.warn("create_user avatar:" + user.avatar.url)
            Authorization.create(:provider => provider, :uid => uid, :token => token, :secret => secret, :user_id => user.id)
            return user
          else
            Rails.logger.warn("User.create_from_hash failed，#{user.email}")
            return nil
          end
        end
      end
    end

    def new_from_provider_data(provider, uid, data)
      User.new do |user|
        user.email = (data["email"].present?) ? data["email"] : "#{uid}@#{provider}.com"
        user.name = (data["name"].present?) ? data["name"] : data["nickname"]
        user.login = (data["nickname"].present?) ? data["nickname"] : data["name"]
        user.password = Devise.friendly_token[0, 20]
        
        user.location = data["location"]        
        user.tagline = data["description"]
        user.language = I18n.locale
        user.timezone = Time.zone.to_s.split(') ')[1]
        user.timezone = "Taipei" if user.timezone == "Beijing"  # special case, just because Marsan is Taiwanese ~ SongLa !
        if (provider == "douban")
          user.location = data["loc_name"] 
          user.tagline = data["desc"]
        end
      end
    end

    def find_avatar(provider, response)
      info = response["info"]  
      case provider
      when "facebook"
        avatar = info["image"].gsub("type=square", "type=large")
        res = Net::HTTP.get_response(URI(avatar))
        avatar = res['location']
      when "twitter"
        avatar = info["image"].gsub("_normal", "")
      when "tqq2"
        avatar = info["image"] + '/180'
      when "weibo"
        avatar = info["image"].gsub('/50/', '/180/')
      when "douban"
        avatar = info["avatar"].gsub('/icon/u', '/icon/ul')
      else
        avatar = email2gravatar(response["info"]["email"], 256)
      end
      Rails.logger.warn("find_avatar avatar:" + avatar)
      return avatar
    end

    def email2gravatar(email, size)
     gravatar_email = Digest::MD5.hexdigest(email.downcase)
     return "http://www.gravatar.com/avatar/#{gravatar_email}?s=" + size.to_s
    end

  end
end
