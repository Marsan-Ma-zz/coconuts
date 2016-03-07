module CpanelHelper
  def cal_word_counts(start_time, end_time)
    posts = Post.where(:published_at.gt => start_time, :published_at.lt => end_time)
    authors = Hash.new
    posts.each do |i|
      if not authors[i.author.name]
        authors[i.author.name] = Hash.new
        authors[i.author.name]["article_count"] = 0
        authors[i.author.name]["word_count"] = 0
      end
      authors[i.author.name]["article_count"] += 1
      authors[i.author.name]["word_count"] += i.content.size
    end
    authors
  end

  def author_posts_title(name, start_time, end_time)
    user_id = User.where(:name => name).first.id
    posts = Post.where(:author_id => user_id, :published_at.gt => start_time, :published_at.lt => end_time)
    titles = posts.map{|i| "#{i.title} (#{i.content.length})"}.join("\n")
  end
end
