#encoding: utf-8  
require 'fileutils'

namespace :dev do
  desc "### Rebuild system ###"
  task :clear => ["tmp:clear", "log:clear"]
  task :build => ["dev:clear", "db:drop", "db:create", "db:migrate"]
  task :rebuild => ["bgjob:stop", "dev:build", "dev:init", "wordpress:feed2beta", "events:init", "recommend:update", "bgjob:start"]
  task :init => :environment do
    init_feeds
    init_notes
    init_sidebar
  end

  task :init_feeds => :environment do
    init_feeds
  end

  def init_feeds  # Initialize feeds IO
    # Mr. Jamie
    script = ".gsub(\/<img class=\"lazy\(\.\*\?\)>\/, '').split('<h3 class=\"related_post_title\">').first.gsub('<h3>', '<p><strong>').gsub('</h3>', '</strong></p>')"
    blog = find_or_create_blogger("jamielin", 'jamie@appworks.tw', 'http://mrjamie.cc/feed', 
                                  false, true, true, script, "business", "【MR JAMIE專欄】", 
                                  "之初創投合夥人，透過育成計畫，幫助早期團隊創業，推動華文網路發展。", 
                                  "https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/jamie.jpg", 100
            )

    # Vista
    script = ".split(\/<div\(\.\*\?\)wp_rp_vertical_m\(\.\*\?\)>/).first"
    blog = find_or_create_blogger("Vista", "iamvista@gmail.com", 'http://blog.vista.tw/feed', 
                                  false, true, true, script, "technology", "【Vista專欄】",
                                  "曾任《數位時代》雜誌主編，目前服務於行動生活產業。關注網路、媒體、科技產業的脈動。",
                                  "https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/vista.jpg", 80
            )

    # Fred
    blog = find_or_create_blogger("Fred", "fredchiang@etusolution.com", 'http://fredbigdata.blogspot.com/feeds/posts/default?alt=rss', 
                                  false, true, true, "", "technology", "【Fred專欄】",
                                  "目前為精誠集團擬定數據價值策略，專長為軟體產業研究、產品發展策略、社群行銷、網路技術應用。",
                                  "https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/fred.jpg", 30
            )

    # Max
    blog = find_or_create_blogger("Max", "hatter10.6@gmail.com", 'http://www.handmadehatter.com/feed/',
                                  false, true, true, "", "business", "【手工帽醬專欄】",
                                  "曾在澳洲、台灣、美國三地工作及創業，《手工帽匠 Handmade Hatter》部落格作者。",
                                  "https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/max.jpg", 20
            )

    # Jollen (have font problem in title, not fit for wordpress, and content only have excerpt, lack of full article.)
    blog = find_or_create_blogger("Jollen", "jollen@jollen.org", 'http://jollen.org/blog/index.xml', 
                                  false, true, true, "", "technology", "【Jollen專欄】",
                                  "Moko365《仕橙3G教室》創辦人，兩岸知名的 Android 與 Linux 技術專家。",
                                  "https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/jollen.jpg", 10
            )

    # Mika 米卡的行銷放肆
    blog = find_or_create_blogger("Mika", "mika.mu@gmail.com", 'http://feeds.feedburner.com/MarketingFuns',
                                  false, true, true, "", "business", "【米卡專欄】",
                                  "「數位、網路、社群媒體、廣告、品牌行銷」講師與顧問。在消費性產業的行銷領域工作了十數年。從品牌策略、商品概念一路到Launch的完整行銷經歷。", 
                                  "https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/mika.jpg", 10
            )

    # ogilvypr 奧美公關藏經閣
    script = ".gsub(\/<span style\(\.\*\?\)>\/, '').split('<div class=\"more\">').first"
    blog = find_or_create_blogger("Ogilvypr", "fupei.wang@ogilvy.com", 'http://feed.pixnet.net/blog/posts/rss/ogilvypr', 
                                  false, true, false, script, "business", "【奧美公關專欄】",
                                  "成立於1987年的奧美公關，隸屬奧美整合行銷傳播集團，為目前台灣最大的公關公司。",
                                  "https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/ogylvypr.jpg", 10
            )

    # Cool3C by 顯二(Atticus)
    blog = find_or_create_blogger("Atticus", "atticus.wu@funmakr.com", 'http://www.cool3c.com/feeds/www/mozilla',
                                  false, true, true, "", "business", "【癮科技】",
                                  "消費電子產品的流行科技網誌與播客",
                                  'https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/atticus.jpg', 20
            )

    # 黛博拉
    script = ".split('<a rel=\"nofollow').first"
    blog = find_or_create_blogger("Debora", "deborah.ema.jong@gmail.com", 'http://feeds.feedburner.com/wordpress/eemyr',
                                  false, true, true, script, "business", "【黛博拉專欄】",
                                  "曾任職於飛利浦半導體與宏達電。目前則是從事翻譯業的家庭主婦。現居住於日本長野縣。",
                                  'https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/debora.jpg', 20
            )

    # MMDays
    script = "\.split(\"http\\\:\\\/\\\/plurktop\")\.first + \"\\\"><\\\/a><\\\/table>\""
    blog = find_or_create_blogger("MMDays", "mr.ms.days@gmail.com", 'http://mmdays.com/feed/',
                                  false, true, true, script, "business", "【MMDays專欄】",
                                  "我們，是一群大學時代同窗的好友，畢業數年後，我們也各自踏上了截然不同的旅程。今天，透過網路和部落格我們再度相聚，以 Mr./Ms. Days (MMDays) 為名，希望每天都能夠跟大家分享我們的所見所聞。",
                                  'https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/mmdays.jpg', 20
            )

    # Kaiak
    blog = find_or_create_blogger("Kaiak", "kaiak@kaiak.tw", 'http://kaiak.tw/feed/',
                                  false, true, true, "", "design", "【城市美學專欄】",
                                  "KAIAK.TW與KOCK MAGAZINE創辦人。為推廣美學、影像、視覺、藝術與創意設計不遺餘力。期待為藝術創作者們創造無限可能性的平台！",
                                  'https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/insider/kaiak.jpg', 20
            )

    # Wired All publish
    Feed.create(:title => "All", :slug => "wiredtw", :comment => "all accessible", :category_ids => [nil], :tag_ids => [nil])
    
    # test
    Feed.create(:title => "Firefox", :slug => "firefox", :comment => "for firefox", :category_ids => [1, nil], :tag_ids => [3, 5, nil])
  end

  def find_or_create_blogger(name, email, feed, publish, copyright, active, script, category, 
                              prefix = nil, tagline = "", avatar_url = Setting.post_dummy_thumbnail, order=0)
    # User
    user = User.where(:email => email).first
    user = User.create(:name => name, :email => email, :is_editor => true, :is_insider => true,
            :password => "wired_blogger", :password_confirmation => "wired_blogger") if not user
    user.tagline = tagline
    user.order = order
    user.remote_avatar_url = avatar_url
    user.save
    cat = Category.where(:slug => category).first
    cat = Category.create(:slug => category, :name => category, :description => category) if not cat
    blog = Blog.where(:feed => feed).first
    blog = Blog.create(:feed => feed, :publish => publish, :copyright => copyright, :active => active, :comment => name, 
            :script => script, :author_id => user.id, :category_id => cat.id, :prefix => prefix) if not blog
  end

  def init_notes  # Initialize Site-Note
    Note.create(:key => "tags_sig", :value => "", :description => "Significant Tag IDs for cpanel form")
    Note.create(:key => "tags_hot", :value => "", :description => "Hot Tag names for cpanel form")
    Note.create(:key => "post_status_counter", :value => "", :description => "Post status counters")
    Note.create(:key => "twitter_page_token", :value => "0", :description => "Twitter發文token,(定期自動更新)")
    Note.create(:key => "twitter_page_secret", :value => "0", :description => "Twitter發文token,(定期自動更新)")
    Note.create(:key => "facebook_bot_token", :value => "0", :description => "Facebook發文token,(定期自動更新)")
    Note.create(:key => "facebook_page_token", :value => "0", :description => "Facebook自動發文token,(定期自動更新)")
    Note.create(:key => "title_quote", :value => "Inventor, Forerunner, and Pioneer.", :description => "首頁大標下的quote.")
    Note.create(:key => "footer_quote", :value => "Wired is the magazine about what's next -- bringing you the people, the trends and the big ideas that will change our lives. Each days, through thought-provoking features and stunning photography, we explore the next big ideas in science, culture, business -- wherever innovation and new thinking are reshaping our world. Since the US edition of Wired launched in 1993, the magazine has been synonymous with informed and intelligent analysis, and a consistently reliable predictor of change. Now, Taiwan Wired is on the road and invite you to with us to be one of the inventor, forerunner, and pioneer.")
    # Open Knowledge
    Note.create(:key => "open_knowledge_main_title", :value => "知識開放計劃 (Open Knowledge)", :description => "Open Knowledge Title")
    Note.create(:key => "open_knowledge_main_txt", :value => 
"    做為科技創新界的主流媒體，WIRED致力於深入探索科技趨勢、產業動向，
    剖析其衍生的影響及巨大變革，為眾多趨勢研究者和評論家們奉為圭臬。

    帶著矽谷改革創新的血統，WIRED選擇台灣作為國際中文版的大本營，要帶領華文世界再一次顛覆科技、文化與產業！

    WIRED將聯合亞太區域的科技單位、產經智庫、研發中心、學界專家及科技社群領袖，
    共同推動「知識開放計劃」(Open Knowledge)，
    將學者專家與先驅者們的研究菁華與前瞻視野，利用網路快速有效率的直達華文世界的每個角落。

    期許Open Knowledge能帶動科技運用及科技創新的浪潮，讓每個人的思考和價值觀能看向國際及未來。
    讓接下來的創新者們得以掌握正確的資源、走上通往成功的坦途，讓世界看見亞洲的新實力！")

    # 總編輯的話
    Note.create(:key => "from_chief_editor", :value =>
"  做為倡導科技創新的主流媒體，WIRED隸屬於全球知名的國際媒體集團「康泰納仕」，
  其影響力遍及歐美及亞太等區域。更是許多科技趨勢研究者及愛好者的主要評論依據。
   
  <b>前瞻 全球科技趨勢</b>
  WIRED一向致力於深入探索科技趨勢、產業動向及國際重要發明，並剖析其將衍生的重大影響及巨大變革，
  尤其著重在商業、政策、文化、娛樂、資通、科學等重要範疇。
   
  <b>探索 亞太科技實力</b>
  21世紀是亞洲發展的重要階段，許多新的科技文明將陸續在亞洲地區創立與實現，也將影響全世界各區域的發展。
  不久的將來，亞洲國家的創新能力及科技實力將獲得愈來愈多的全球關注。
   
  <b>分享 增進科技創新</b>
  國際分工板塊正在快速移轉，各國對於區域知識發展，應更加密切交流及合作。
  WIRED團隊將聯合亞太區主要國家的科技單位、產經智庫、研發中心、產業專家及科技社群領袖，
  共同推動知識開放計劃 (Open Knowledge)，致力於讓正確的資訊與知識有效率的分享及傳播。
  期許Open Knowledge能帶動科技運用及科技創新的浪潮，以增進全球的科技文明。
   
  <b>使命與挑戰</b>
  如何讓全球看見亞洲科技實力是我們的主要目標，同時，也要讓華人社群對於全球科技趨勢能有更深入的瞭解、
  更廣泛的認知及更有效率的運用，這些都是WIRED.tw國際中文編輯群的神聖使命與挑戰。")
  end
  
  def init_sidebar
    Sidebar.create(:order => 10, :title => "Events", :comment => "Wired Events", :active => true,
                    :content => '<a href="/events/open_knowledge"><img alt="Open-knowledge-header" src="https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/events/open-knowledge-header.jpg" width="100%"></a><a href="/events/2013_spring_forum"><img alt="300x100" src="http://wiredtw.s3.amazonaws.com/wp-content/uploads/2013/03/300x100.jpg" width="100%"></a>' )
  end

end

