source 'https://rubygems.org'

#=========================================
#   Web Main
#=========================================
# main
gem 'rails', '3.2.11'
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'compass-rails'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end
gem 'jquery-rails'
gem "puma", ">= 1.6.3"
gem "mongoid", ">= 3.0.19"
gem 'mongoid_auto_increment_id'
gem 'mongoid_rails_migrations'

gem "therubyracer", ">= 0.11.3", :group => :assets, :platform => :ruby, :require => "v8"

#=========================================
#   General use
#=========================================
# settings
gem "settingslogic"

# auth
gem "devise", ">= 2.2.3"
gem "cancan"
gem "figaro", ">= 0.5.3"
gem "libv8", ">= 3.11.8"
gem "omniauth"
gem "omniauth-facebook"
gem "omniauth-twitter"
gem "omniauth-openid"
gem 'omniauth-tqq-oauth2'
gem "omniauth-weibo-oauth2"
gem "omniauth-douban-oauth2"
gem "fql"

# i18n
gem 'http_accept_language'  # get l10n info from browser
gem 'countries_and_languages'
gem 'chinese_pinyin'  # translate chinese to pinyin, for slug_sanitize

# image upload
gem 'carrierwave' # Note: have to install imagemagick: sudo apt-get install imagemagick
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'fog'         # rails cloud handle for amazon S3
gem 'mini_magick','3.3', :require => false

# Redis-server
gem "redis-namespace"
gem "redis-objects"
gem "redis-dump"
gem "redis-store"
gem "redis-rails"


# Background Jobs
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'whenever', :require => false
gem 'sinatra', :require => false
gem 'slim'

# Feeds
gem 'feedzirra'
gem 'nokogiri'
#gem 'open-uri'
gem 'json'
#gem 'net/http'
gem 'mysql2', '~> 0.3.11'
gem 'htmlentities'

# UI
gem "kaminari"
gem 'simple_form'
gem 'nested_form'
gem "combined_time_select"

# Social Network (Google+ have no writable API, use HootSuite to make G+ subscribe feed!)
gem 'koala'   # http://stackoverflow.com/questions/10036728/post-to-a-facebook-page-not-user-page-using-koala
gem 'twitter' # gem cert --add <(curl -Ls https://gist.github.com/sferik/4701180/raw/public_cert.pem), gem install twitter -P HighSecurity
gem 'twitpic-full'
gem 'googl'   # google url-shorten tool
gem "capybara", "~> 2.0.2"
gem 'capybara-webkit'
gem 'social-share-button'
gem "social-buttons"
gem "chinese_convt" # zh-TW, zh-CN convertion

## SEO
gem 'sitemap_generator'
gem 'meta-tags', :require => 'meta_tags'

# edit tool
gem 'diffy'

#=========================================
#   Infrastructure
#=========================================
# development
gem "rspec-rails", ">= 2.12.2", :group => [:development, :test]
gem "factory_girl_rails", ">= 4.2.0", :group => [:development, :test]
group :development do
  gem "quiet_assets", ">= 1.0.1"
  gem "better_errors", ">= 0.3.2"
  gem "binding_of_caller", ">= 0.6.8"
  gem 'capistrano', :require => false
  gem 'rvm-capistrano', :require => false
  gem 'sanitize', :require => false
end

# test
group :test do
  gem "database_cleaner", ">= 0.9.1", :group => :test
  gem "mongoid-rspec", ">= 1.6.0", :group => :test
  gem "email_spec", ">= 1.4.0", :group => :test
  gem "cucumber-rails", ">= 1.3.0", :group => :test, :require => false
  gem "launchy", ">= 2.1.2", :group => :test
  gem "rb-readline"
  gem "request-log-analyzer"
end

