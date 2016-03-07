# encoding: utf-8
class HourlyWorker
  include Sidekiq::Worker
  #sidekiq_options queue: "high"  # change this shall add some config, else worker will not start. see document.
  # sidekiq_options retry: false

  def perform
    begin
      #update_fanpages
    rescue => e
      puts e
    end
  end

  def update_fanpages
    Post.where(:published_at.gt => Time.now - 1.week, :post2social => true, :post2social_done => false).each do |post|
      post.post2facebook
      post.post2twitter
      post.update_attributes(:post2social_done => true)
    end
  end

end
