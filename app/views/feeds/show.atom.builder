atom_feed :language => 'en-US' do |feed|
  feed.title @feed.title
  feed.updated @timestamp
  @posts.each do |post|
    next if post.updated_at.blank?
    feed.entry(post) do |entry|
      entry.title post.title
      entry.content :type => "html" do 
        entry.cdata! render :partial => "feeds/related", :locals => {:post => post, :related_posts => related_posts(post)}
      end 
      for tag in post.tags
        entry.category :term => posts_url(tag.slug), :label => tag.name
      end
      entry.author do |author|
        author.name post.author.name
      end
    end
  end
end
