# encoding: utf-8
class MinuteWorker
  include Sidekiq::Worker
  #sidekiq_options queue: "high"  # change this shall add some config, else worker will not start. see document.
  # sidekiq_options retry: false

  def perform
    publish_scheduled
  end

  private

  def publish_scheduled
    Post.where(:status => "scheduled", :published_at.lt => Time.now).each do |i|
      i.status = "published"
      i.save
    end
  end

end
