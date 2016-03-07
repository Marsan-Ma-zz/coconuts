# coding: utf-8
module PostsHelper
  def post_status_array
    ["Published", "Scheduled", "Pending", "Draft", "External", "Consult", "Raw", "Unknown", "Trashed"]
  end

  def post_status(post)
    content_tag(:small, "(#{post.status})", :class => "#{post.status.downcase}")
  end

  def post_date(time)
    time.strftime("%Y %b %d, %a")
  end

  def post_css_class(name)
    class_name = case name.downcase
      when "technology" then "tech"
      when "business" then "biz"
      when "science" then "sci"
      when "people" then "ppl"
      when "entertainment" then "ent"
      when "design" then "design"
      when "gadget" then "gadget"
      else "biz"
    end
  end

  def post_author(post)
    a = post.cites.where(:source => 'author').first
    author_name = a ? a.name : post.author.name
  end

  def post_status_options(user)
    if user.admin?
      options = ["published", "scheduled", "pending", "draft", "external", "consult", "raw", "unknown", "trashed"]
    else
      options = [                          "pending", "draft", "external", "consult", "raw", "unknown", "trashed"]
    end
  end

  def related_posts(post, num=5)
    posts = Post.where(:tag_ids.in => post.tag_ids, :status => "published").not_in(:id => post.id).sample(num)
    if (posts.count < num)  
      rand = Post.where(:status => "published").desc(:updated_at).limit(100)  # if not enough, add latest 100 posts
      posts = (posts + rand).uniq.sample(num)
    end
    posts
  end

  def trim_time(time)
    time.to_s[11..12] + ":00:00"
  end

  def post_original(post)
    source = post.cites.where(:source => "written").first
    author = post.cites.where(:source => "author").first
    if (source && author)
      content_tag(:p) do
        concat "來看看原作者"
        concat link_to(author.name, iframe_path("full", :inner => source.url), :target => "_blank")
        concat "在"
        concat link_to(source.name, iframe_path("full", :inner => source.url), :target => "_blank")
        concat "的觀點吧！"
      end
    elsif source
      content_tag(:p) do
        concat "歡迎你也看看原文作者"
        concat link_to(source.name, iframe_path("full", :inner => source.url), :target => "_blank")
        concat "的說法。"
      end
    elsif post.original
      content_tag(:p) do
        concat "(本篇文章的出處"
        concat link_to("來源見此", iframe_path("full", :inner => post.original), :target => "_blank")
        concat ")"
      end
    else
      ""
    end
  end

end
