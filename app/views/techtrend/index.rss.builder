xml.rss :"xmlns:content" => "http://purl.org/rss/1.0/modules/content/", 
        :"xmlns:wfw" => "http://wellformedweb.org/CommentAPI/", 
        :"xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        :"xmlns:atom" => "http://www.w3.org/2005/Atom",
        :"xmlns:sy" => "http://purl.org/rss/1.0/modules/syndication/",
        :"xmlns:slash" => "http://purl.org/rss/1.0/modules/slash/",
        :version => "2.0" do
  xml.channel do
    xml.title @feed_title
    xml.tag!("atom:link", :href => "http://#{Setting.domain}/techtrend", :rel => "self",  :type => "application/rss+xml")
    xml.description "Tech News curation techtrend"
    xml.link "http://#{Setting.domain}/"
    xml.lastBuildDate @timestamp.to_s(:rfc822)
    xml.tag!("language", "zh-TW")
    xml.tag!("sy:updatePeriod", "hourly")
    xml.tag!("sy:updateFrequency", "1")
    @bullets.each do |bullet|
      xml.item do
        xml.title bullet.title
        xml.pubDate bullet.created_at.to_s(:rfc822)
        xml.tag!("dc:creator", bullet.source)
        xml.description { xml.cdata!(bullet.summary) }
        xml.content(:encoded) { xml.cdata!(bullet.summary) }
        xml.link bullet.link
        xml.guid bullet.link
      end
    end
  end
end
