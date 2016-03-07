atom_feed :language => 'en-US' do |feed|
  feed.title @feed_title
  feed.updated @timestamp
  @bullets.each do |bullet|
    next if bullet.summary.empty?
    feed.entry(bullet) do |entry|
      entry.title bullet.title
      entry.content :type => "html" do 
        entry.cdata! bullet.summary
      end 
      entry.author do |author|
        author.name bullet.source
      end
    end
  end
end
