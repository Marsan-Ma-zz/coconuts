# coding: utf-8
class TechtrendController < ApplicationController
  #layout "no_sidebar"
  layout "no_sidebar", :only => ["index"]

  def index
    # for html
    @mp_class = "category"  # for css

    # select language
    bullets = (params[:lang] == "en") ? Bullet.where(:lang => "en") : Bullet.where(:lang.in => ["zh", "zhcn"])
    bullet_seo(params[:lang], bullets.first)

    # choose source
    #bullets = bullets.where(:source => params[:source]) if params[:source]

    # select mode
    case params[:sort]
    when "hottest"
      bullets = bullets.desc(:relate_count)
    when "popular_week"
      bullets = bullets.where(:created_at.gt => Time.now - 1.week).desc(:curate_score)
    when "popular_month"
      bullets = bullets.where(:created_at.gt => Time.now - 1.month).desc(:curate_score)
    when "popular_year"
      bullets = bullets.where(:created_at.gt => Time.now - 1.year).desc(:curate_score)
    when "favorite"
      bullets = current_user.collections
    else #latest
      bullets = bullets.desc(:created_at)
    end
    @bullets = bullets.page(params[:page])
    @eop = params[:page] ? (params[:page].to_i > @bullets.num_pages) : false

    # for rss
    @feed_title = "TechTrend"
    @timestamp  = @bullets.empty? ? Time.now : @bullets.first.created_at
    respond_to do |format|
      format.html # index.html.erb
      format.js   # for infinite-scroll
      format.atom { render :layout => false }
      format.rss { render :layout => false }
    end
  end

  def show
  end

  def inform
    BulletsWorker.perform_async(params[:path]) if (params[:path] && (File.exist?(params[:path])))
    #local_path = params[:path]
    ## 1st run, create all bullets
    #File.open(local_path).each_line do |line|
    #  line = JSON.parse(line)
    #  bul = Bullet.where(:link => line['link']).first
    #  if not bul
    #    bul = Bullet.create(:title => line['title'], :summary => line['summary'], :content => line['content'],
    #                        :link => line['link'], :source => line['src'], :thumbnail => line['thumb'],
    #                        :created_at => line['created_at'], :updated_at => line['updated_at'])
    #    puts "[SAVE] #{line['title']}"
    #  end
    #end

    ## 2nd run, build related topics
    #puts "[2nd run, build related topics]"
    #File.open(local_path).each do |line|
    #  line = JSON.parse(line)
    #  bul = Bullet.where(:link => line['link']).first
    #  if bul
    #    puts "[Linking] #{bul.title}"
    #    relates = JSON.parse(line['relate'])
    #    r_ids = []
    #    for i in relates.keys
    #      print i
    #      t = Bullet.where(:link => i).first
    #      bul.push(:related_ids, t.id) if not bul.related_ids.include?(t.id)
    #      puts "[Relate] #{bul.title} / #{t.title}"
    #    end
    #  else
    #    puts "[Error] while linking #{line['link']}"
    #  end
    #end
  end

  private

  def bullet_seo(lang, bullet)
    case lang
    when "en"
      title = "TechTrend"
      description = "Global TechTrend ranked in latest and most curated."
      keywords = "Tech, Trend, Global, Rank, latest, curated"
    else
      title = "全球科技趨勢排行榜" 
      description = "與全球科技媒體內容同步更新！追蹤最新趨勢，彙整國內外本周內和本月內最被關注的議題！"
      keywords = "科技, 趨勢, 國內外, 媒體, 排行, 策展"
    end
    url = "http://beta.wired.tw/techtrend"
    set_meta_tags :title => title, :description => description, :keywords => keywords
    set_meta_tags :twitter => {
      :card => "summary",
      :site => "@wired_tw",
      :creator => "@wired_tw", 
      :url => url,
      :title => title,
      :description => description,
      :image => bullet.thumbnail
    }
    set_meta_tags :og => {
      :title    => title,
      :type     => 'article',
      :url      => url,
      :site_name => "Wired.TW",
      :description => description,
      :image    => bullet.thumbnail
    }
    set_meta_tags :fb => {
      :app_id   => "337912959569337",
      :image    => bullet.thumbnail,
      :title    => title,
      :type     => 'article',
      :url      => url,
      :site_name => "Wired.TW",
      :description => description
    }
  end

end
