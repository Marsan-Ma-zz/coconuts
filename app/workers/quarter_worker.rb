# encoding: utf-8
class QuarterWorker
  include Sidekiq::Worker
  #sidekiq_options queue: "high"  # change this shall add some config, else worker will not start. see document.
  # sidekiq_options retry: false

  def perform
    scan_bloggers
  end

  private

  def scan_bloggers
    Blog.where(:active => true).each do |blog|
      blog.import_blog
    end
  end

end
