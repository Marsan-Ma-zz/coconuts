# coding: utf-8
class Cpanel::ApplicationController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_login
  before_filter :require_editor
  layout "cpanel"

  def clear_cache(params)
    redis = Redis.new(:host => Setting.redis_server, :port => Setting.redis_port)
    case params[:cache]
      when 'clear_posts'
        clear_cache_match(redis, ["wired_post"])
      when 'clear_home'
        clear_cache_match(redis, ["wired_home", "wired_footer", "wired_sidebar"])
      when 'clear_feeds'
        clear_cache_match(redis, ["rss", "atom"])
      when 'clear_jobs'
        puts "[Clear all background jobs views]"
    end
  end

  def clear_cache_match(redis, keys)
    keys.each do |i|
      redis.keys("*#{i}*").each do |j|
        redis.del(j)
      end
    end
  end


end
