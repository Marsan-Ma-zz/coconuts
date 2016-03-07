# encoding: utf-8
class DailyWorker
  include Sidekiq::Worker
  #sidekiq_options queue: "high"  # change this shall add some config, else worker will not start. see document.
  # sidekiq_options retry: false

  require 'capybara/dsl'
  include Capybara::DSL
  Capybara.current_driver = :webkit
 
  def perform
    begin
      update_twitter_bot_token
      update_facebook_bot_token
    rescue => e
      #puts e
    end
  end

  def update_twitter_bot_token
    Capybara.visit("http://#{Setting.domain}/users/auth/twitter")
    if page.has_css?("#username_or_email") # first-time login
      Capybara.find("#username_or_email").set(Setting.twitter_bot_name)
      Capybara.find("#password").set(Setting.twitter_bot_pass)
    end
    Capybara.find("#allow").click if page.has_css?("#allow")
    Capybara.find("#sign_out").click if page.has_css?("#sign_out")
    auth = User.where(:name => "#{Setting.twitter_id}").first.authorizations.where(:provider => "twitter").first
    Note.where(:key => "twitter_page_token").first.update_attributes(:value => auth.token)
    Note.where(:key => "twitter_page_secret").first.update_attributes(:value => auth.secret)
  end

  # Fail Cause: 1. password error, 2. app-ID error, 3. redirect path error, 4. development/production setup mixed
  def update_facebook_bot_token
    oauth = Koala::Facebook::OAuth.new(Setting.fb_bot_token, Setting.fb_bot_secret, "http://#{Setting.domain}/")
    login_path = oauth.url_for_oauth_code(:permissions => "publish_stream, manage_pages")
    Capybara.visit(login_path)
    if page.has_css?("#email") # first-time login
      Capybara.find("#email").set(Setting.fb_bot_name)
      Capybara.find("#pass").set(Setting.fb_bot_pass)
      Capybara.find("#loginbutton//input").click
    end
    Capybara.find("#grant_required_clicked//input").click if page.has_css?("#grant_required_clicked//input")
    Capybara.find("#grant_clicked//input").click if page.has_css?("#grant_clicked//input")
    Capybara.find("#sign_out").click if page.has_css?("#sign_out")
    code = current_url.split('=')[-2][0..-3]
    token = oauth.get_access_token_info(code) # this server-side authorized token last for 60 days
    Note.where(:key => "facebook_bot_token").first.update_attributes(:value => token["access_token"])
    # get wired token
    graph = Koala::Facebook::API.new(token["access_token"])
    accounts = graph.get_connections("me", "accounts")
    page_token = accounts.select{|i| i["name"] == "WIRED.tw"}.first["access_token"]
    Note.where(:key => "facebook_page_token").first.update_attributes(:value => page_token)
  end

  def update_gplus_bot  # un-finished, Google+ API still read only. No known work-around
    ## login
    #Capybara.visit("https://accounts.google.com/Login")
    #Capybara.find("#Email").set(Setting.google_bot_name)
    #Capybara.find("#Passwd").set(Setting.google_bot_pass)
    #Capybara.find("#signIn").click
    #Capybara.visit("https://plus.google.com/u/0/110418245137480784004/posts")
    ## input
    #doc = Nokogiri::HTML.parse(body)
    #Capybara.click_link('新增連結')
    #Capybara.find(".editable").set("http://wired.tw/2013/03/08/super-absorbent-cotton-irrigation/index.html test haha ~")
    #Capybara.click_link('分享')
  end

end
