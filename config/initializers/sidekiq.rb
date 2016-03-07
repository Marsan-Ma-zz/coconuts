Sidekiq.configure_server do |config|
  config.redis = { :url => "redis://#{Setting.redis_server}:#{Setting.redis_port}/12", :namespace => "#{Setting.app_name}"}
end

# When in Unicorn, this block needs to go in unicorn's `after_fork` callback:
Sidekiq.configure_client do |config|
  config.redis = { :url => "redis://#{Setting.redis_server}:#{Setting.redis_port}/12", :namespace => "#{Setting.app_name}"}
end

