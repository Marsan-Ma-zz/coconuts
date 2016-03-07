#encoding: utf-8  

namespace :recommend do
  desc "### Update Recommend Channels ###"

  task :clear => :environment do
    Note.where(:key => /RC_/).each do |i|
      i.value = ""
      i.save
    end
  end

  task :update => :environment do
    sources = [ ["TED", 'http://feeds.feedburner.com/Tedxtaipei'], 
                ["NSC", 'http://www.nsc.gov.tw/scitechvista/zh-tw/RSS/C/5.htm'], 
                ["PANSCI", 'http://pansci.tw/feed'],
                ["PANSCI_ASK", 'http://ask.pansci.tw/feed']
              ]
    sources.each do |s|
      begin
        note = update_latest_rss(s[0], s[1])
      rescue
        puts "[Error] in importing recommended reading: #{s[0]}"
      end
    end
    begin
      note = update_latest_guokr("GUOKR", 'http://www.guokr.com/site/fact/') 
    rescue
      puts "[Error] in importing recommended reading: Guokr"
    end
  end

  private

  def update_latest_rss(name, feed)
    raw = Feedzirra::Feed.fetch_and_parse(feed).entries rescue []
    if (i = raw.first)
      body = Nokogiri::HTML(i.content)
      excerpt = trim(i.summary.gsub(/<(.*?)>/,''), 200)
      case name
      when "NSC"
        begin
          img = Nokogiri::HTML(open(i.url)).css(".news_pic img").first.attr("src").gsub(/(.*?)wh/, 'http://www.nsc.gov.tw/scitechvista/zh-tw/wh')
          img = img_uploader("RC_#{name}", img).photo.url
        rescue
          img = 'https://wired-tw.s3.amazonaws.com/photo/ac8aaba8-9db6-428e-94ec-62746e11e04d.jpg'
        end
      when "PANSCI"
        img = body.css("img").first.attr("src") rescue 'https://wired-tw.s3.amazonaws.com/photo/18a3cd44-10d8-4e60-a281-4281e02ef781.png'
        img = img_uploader("RC_#{name}", img).photo.url
      when "PANSCI_ASK"
        img = 'https://wired-tw.s3.amazonaws.com/photo/18a3cd44-10d8-4e60-a281-4281e02ef781.png'
      when "TED"
        iframe = body.css("iframe").first.attr("src") rescue ""
        img = body.css("img").first.attr("src") rescue ""
        img = img_uploader("RC_#{name}", img).photo.url if not iframe
      end
      if iframe
        mtype, banner = "iframe", iframe # use video first, use img if no video
      else
        mtype, banner = "img", img
      end
      item = {"name" => name, "link" => i.url, "title" => i.title,
              "author" => i.author, "excerpt" => excerpt, "published" => i.published,
              "mtype" => mtype, "banner" => banner}
      save_note("RC_#{name}", item)
    else
      puts "[ERROR] in #{name}/#{feed} at #{Time.now.to_s}"
    end
  end

  def update_latest_guokr(name, feed)
    i = Nokogiri::HTML(open(feed)).css(".article-item").first
    link = i.css("a").first.attr("href")
    title = Chinese.zh2tw(i.css("h3").first.content.strip)
    author = Chinese.zh2tw(i.css(".article-fun a").first.content.strip)
    img = img_uploader("RC_#{name}", i.css("img").first.attr("src")).photo.url
    published_at = i.css(".article-fun").first.content.strip.split(" ").first[-10..-1]
    excerpt = Chinese.zh2tw(i.css(".article-summary").first.content.split("阅读全文").first.strip)
    item = {"name" => name, "link" => link, "title" => title,
            "author" => author, "excerpt" => excerpt, "published" => published_at,
            "mtype" => "img", "banner" => img}
    save_note("RC_#{name}", item)
  end

  def save_note(key, value)
    note = Note.where(:key => key).first
    if note
      note.update_attributes(:value => value)
    else
      note = Note.create(:key => key, :value => value)
    end
    note
  end

  def trim(txt, length)
    half = txt.gsub(/[\p{Han}]/, '').length
    full = txt.length - half
    trimtxt = (half/2 > full) ? txt[0..length-1] : txt[0..length/2-1]
    trimtxt += '...' if (trimtxt.length < txt.length)
    trimtxt
  end

  def img_uploader(title, src)
    slug = Pinyin.t(title, '_').gsub(/[^\w]/, "_").downcase.gsub(/__*/, '_')[0..63]
    tmp = img_downloader(slug, src)
    Photo.where(:title => slug, :slug => slug).each{|i| i.destroy}
    img = Photo.new(:title => slug, :slug => slug)
    img.photo.store!(open(tmp))
    img.save
    img
  end

  def img_downloader(filename, src)
    save_path = "tmp/#{filename}"
    open(src) {|f|
      File.open(save_path,"wb") do |file|
        file.puts f.read
      end
    }
    save_path
  end

end

