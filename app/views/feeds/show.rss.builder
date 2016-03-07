xml.rss :"xmlns:content" => "http://purl.org/rss/1.0/modules/content/", 
        :"xmlns:wfw" => "http://wellformedweb.org/CommentAPI/", 
        :"xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        :"xmlns:atom" => "http://www.w3.org/2005/Atom",
        :"xmlns:sy" => "http://purl.org/rss/1.0/modules/syndication/",
        :"xmlns:slash" => "http://purl.org/rss/1.0/modules/slash/",
        :version => "2.0" do
  xml.channel do
    xml.title @feed.title
    xml.tag!("atom:link", :href => "http://#{Setting.domain}/rss", :rel => "self",  :type => "application/rss+xml")
    xml.description "Wired RSS Feed"
    xml.link "http://#{Setting.domain}/"
    xml.lastBuildDate @timestamp.to_s(:rfc822)
    xml.tag!("language", "zh-TW")
    xml.tag!("sy:updatePeriod", "hourly")
    xml.tag!("sy:updateFrequency", "1")
    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.pubDate post.published_at.to_s(:rfc822)
        xml.tag!("dc:creator", post.author.name) if post.author.name
        post.categories.each do |i|
          xml.tag!("category", i.name)
        end
        xml.description { xml.cdata!(post.excerpt) }
        xml.content(:encoded) {xml.cdata!(render :partial => "feeds/related", 
                               :locals => {:post => post, :related_posts => related_posts(post)})}
        xml.link post_url(post.slug)
        xml.guid post_url(post.slug)
      end
    end
  end
end
