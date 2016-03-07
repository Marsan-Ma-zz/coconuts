# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://beta.wired.tw"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'

  # Index
  add posts_path, :priority => 0.7, :changefreq => 'daily'
  add features_path, :priority => 0.7, :changefreq => 'daily'

  # Records
  Post.find_in_batches(:batch_size => 100) do |i|
    i.each do |j|
      add post_path(j.slug), :lastmod => j.updated_at
    end
  end
  Feature.find_in_batches(:batch_size => 100) do |i|
    i.each do |j|
      add feature_path(j.slug), :lastmod => j.updated_at, :changefreq => 'daily'
    end
  end

  # Events
  add event_path(:id => "open_knowledge"), :changefreq => 'daily'
  add event_path(:id => "big_data_magzine"), :changefreq => 'daily'
end
