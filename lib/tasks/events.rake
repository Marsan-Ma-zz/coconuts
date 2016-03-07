#encoding: utf-8

namespace :events do
  desc "### Rebuild event ###"
  task :rebuild => ["events:clear", "events:init"]
  task :clear => :environment do
    Feature.each{|i| i.destroy}
  end
  task :init => :environment do
    init_event_posts_bigdata
    init_events
    init_headlines
  end
 
  def init_headlines
    post_ids = Post.where(:published_at.lt => Time.now).desc(:published_at).limit(5).map(&:id)
    Note.where(:key => /home_carousel_/).each{|i| i.destroy}
    for i in 0..4 do
      Note.create(:key => "home_carousel_#{i}", :value => "#{post_ids[i]}", :description => "首頁跑馬燈文章id") 
    end
  end
 
  def init_events
    db = Mysql2::Client.new(:host => Setting.wp_sql, :username => Setting.wp_dbname, :database => Setting.wp_dbname, :password => Setting.wp_dbpassword)
    query = 'SELECT * FROM `wired_feature_main`'
    events = Hash.new {|h,k| h[k] = [] }
    events[3] << Post.where(:title => /國民黨青年軍力攻新媒體/).first.id
    events[3] << Post.where(:title => /民進黨拼青年選票/).first.id
    raws = db.query(query).to_a.map{|i| [slug_sanitize(i["pic_href"].split('/')[-2]), i["ymd"].month]}
    raws.each do |i|
      post = Post.where(:slug => i[0]).first
      events[i[1]] << post.id if post
    end
    events[6] << Post.where(:title => /顛覆傳統生產機制/).first.id
    events.each do |i|
      events[i[0]] = i[1].join(' ')
    end

    Feature.create(:title => '新．無政府主義：科技治國的時代來臨', :slug => "digital_gov", :excerpt => 'Welcome, Politech! 在物物上網、什麼事都離不開網路的年代，就連最傳統、最封閉的政治，也得嘗試跟上科技的腳步，學會駕馭這些危險又迷人的工具。', :thumbnail => 'https://s3-ap-southeast-1.amazonaws.com/wiredtw/wp-content/uploads/2012/03/banner_460x400.jpg', :published_at => '2012-03-30', :post_ids => events[3])
    Feature.create(:title => 'The Big Picture：我們，正在改變世界', :slug => 'changing_world', :excerpt => 'TEDxChange旨在綜觀全局、重新審視個人與世界的關係。2012年，《Wired》特別與TEDxTaipei合作，透過系列報導，揭露台灣正在面臨的巨大變革。', :thumbnail => 'https://s3-ap-southeast-1.amazonaws.com/wiredtw/wp-content/gallery/feature/banner_460x400-1.jpg', :published_at => '2012-04-30', :post_ids => events[4])
    Feature.create(:title => '《Wired》前進矽谷特別報導', :slug => "silicon_valley_2012", :excerpt => '《Wired》前進矽谷，專訪美國《Wired》現任總編輯Chris Anderson、創辦人Kevin Kelly；同時造訪連續創業家crowdmob、crowdbooster ，以及Flipboard、Zarrly等話題公司。', :thumbnail => 'https://s3-ap-southeast-1.amazonaws.com/wiredtw/wp-content/gallery/feature/banner_460x400-1_0.jpg', :published_at => '2012-05-30', :post_ids => events[5])
    Feature.create(:title => 'From Online to Offline：除了按讚，社群能讓世界更讚的方法', :slug => "from_online_to_offline", :excerpt => '1993年，《Wired》曾預言，網路將會茁壯到成為一個國家；19年後的今天，Facebook以超過9億的會員人數，穩坐世界第三大國。這股社群網路熱潮究竟能帶來多少實質回饋？答案或許就在《Wired》的案例報導。', :thumbnail => 'https://s3-ap-southeast-1.amazonaws.com/wiredtw/wp-content/gallery/on-line-to-off-line/banner_460x400.jpg', :published_at => '2012-06-30', :post_ids => events[6])
    Feature.create(:title => 'GEEK當道：科技怪咖從小做起', :slug => "geek_rule", :excerpt => '培養一個Geek Kid的重要性在於讓孩子理解：生活並不如表面所見的理所當然，主動發掘背後成因，透過實際經驗自我學習，才是創新的原動力；台灣教育若只重功利，如何培養出具原創力的下一代？', :thumbnail => 'https://s3-ap-southeast-1.amazonaws.com/wiredtw/wp-content/uploads/2012/08/470x398_01.jpg', :published_at => '2012-08-30', :post_ids => events[8])
    Feature.create(:title => 'Big Data, Big Thinking', :slug => "big_data", :excerpt => '當資料已經變成一種新的經濟資產，不論你處在哪個產業，都不能不懂這個雲端時代的黃金貨幣-Big Data。這個由大數據所引爆的資料革命，已經促使各行各業面臨轉型的決勝關鍵點。', :thumbnail => 'http://www.wired.com/wiredenterprise/wp-content/uploads//2012/10/ff_googleinfrastructure_f.jpg', :published_at => '2013-04-15', :post_ids => "/events/big_data_magzine")
  end

  def init_event_posts_bigdata
    event_posts = Hash.new
    for i in 1..8
      event_posts[i] = Post.where(:slug => /bdma_#{i}_/).asc(:slug).map(&:id).join(' ')
    end
    Feature.where(:slug => /big_data_part_/).each{|i| i.destroy}
    Feature.create(:title => "PART 1 : EXABYTE REVOLUTION", :slug => "big_data_part_1", :excerpt => "Google之所以是Google，來自於它的實體網路、長達數千哩的光纖，以及好幾萬個共同催生出雲端的伺服器。由於Google視網路為終極競爭優勢，向來只有最核心的員工才能一窺其內部。這次，美國《WIRED》資深記者Steven Levy將帶著我們，一同進入這個擁有令人難以置信的效能與速度、從不對外開放、位於愛荷華州的伺服器室，獨家直擊Google最機密的全球資料中心「The Floor」。", :thumbnail => "http://www.wired.com/wiredenterprise/wp-content/uploads//2012/10/ff_googleinfrastructure_f.jpg" , :published_at => '2013-04-10', :post_ids => event_posts[1], :public => false)
    Feature.create(:title => "PART 2 : Next Big Business", :slug => "big_data_part_2", :excerpt => "「買了這個的，也買了那個」的實際消費記錄，是令廣告客戶垂涎的資料。不過，亞馬遜還不打算賣這個， 先賣出的會是「看了這個的，也看了那個」。", :thumbnail => "http://farm1.staticflickr.com/24/62909865_58a9705ccb_z.jpg" , :published_at => '2013-09-06', :post_ids => event_posts[2], :public => false)
    Feature.create(:title => "PART 3 : Mr.Big", :slug => "big_data_part_3", :excerpt => "數據目的不是把它存起來，而是從中提煉出商業價值。隨著行動裝置、雲端技術的發展，促進了資料大爆炸，現在有很多廠商看到數據真正的商業價值。", :thumbnail => "http://wiredtw.s3.amazonaws.com/wp-content/uploads/2013/04/MG_9286.jpg" , :published_at => '2013-09-07', :post_ids => event_posts[3], :public => false)
    Feature.create(:title => "PART 4 : Big Thinking", :slug => "big_data_part_4", :excerpt => "霍夫曼認為，社交網路應該嚴肅看待個人資料持有的議題，「LinkedIn採取的是共同擁有的角度，」他表示，「我們會盡可能提供最精準的個人選擇，協助用戶達成目標，因此，用戶可以下載自己的完整連結清單，轉存為CSV檔，但不允許由第三方服務代勞。」", :thumbnail => "http://cdni.wired.co.uk/620x413/a_c/1_620x413_28.jpg" , :published_at => '2013-09-08', :post_ids => event_posts[4], :public => false)
    Feature.create(:title => "PART 5 : FUTURE: Hadoop", :slug => "big_data_part_5", :excerpt => "許多曾經待過知名網路公司的好手都加入了Cloudera：雅虎工程副總裁阿瓦達拉（Amr Awadallah）、臉書資料經理漢默巴卻（Jeff Hammerbacher）、曾在華盛頓大學開設Google「巨量資料」課程的比希利亞（Christophe Bisciglia）。他們想在Hadoop複製類似紅帽推展Linux的模式，也就是以一家公司的力量，提供服務、支援、額外軟體給Hadoop開放原始碼平台。", :thumbnail => "http://wiredtw.s3.amazonaws.com/wp-content/uploads/2013/03/meituan1.jpg" , :published_at => '2013-09-09', :post_ids => event_posts[5], :public => false)
    Feature.create(:title => "PART 6 : BIG INSIGHTS", :slug => "big_data_part_6", :excerpt => "2007年11月，民主黨總統候選人歐巴馬到Google山景城（Mountain View）總部演說，席洛克當時是Google瀏覽器小組的產品經理。看到來聽演說的大批人群，他決定從後門溜進會場，「我走上前告訴安全人員，『我要進去開會，』」其實根本沒有會議，但席洛克鼓起勇氣撒的謊，讓他成功混進會場。", :thumbnail => "http://www.wired.com/wiredenterprise/wp-content/gallery/20-05/ff_abtesting_f.jpg" , :published_at => '2013-09-10', :post_ids => event_posts[6], :public => false)
    Feature.create(:title => "PART 7 : UNLEASHING INNOVATION", :slug => "big_data_part_7", :excerpt => "在奧斯卡獎頒獎典禮這樣的場合裡，具有特定共通興趣或嗜好的使用者，大量聚集在特定媒體前，並透過社群網絡把得來的訊息加值散播出去，像是螢火蟲在網路世界裡串連成一個個發光的熱點，構成不可忽視的行銷商機。這也解釋了美國超級盃美式足球賽的廣告費，每30秒要價高達400萬美金，但對企業主來說，如何讓天價般的廣告支出發揮最大效益？", :thumbnail => "http://wiredtw.s3.amazonaws.com/wp-content/uploads/2013/03/cnsuning3.jpg" , :published_at => '2013-09-11', :post_ids => event_posts[7], :public => false)
    Feature.create(:title => "PART 8 : SMART CITY, NEW LIFE", :slug => "big_data_part_8", :excerpt => "2012年的倫敦奧運，創了許多紀錄，其中，有項從未有過的紀錄是，它不只是社群奧運，更是Big data奧運。2012年才剛落幕的倫敦奧運，讓世人看見英國深厚的文化底蘊，重溫她每回驅動世界前進的歷史，不論從社會、文化、科技等方面來看，英國帶動了好幾次人類文明的創新。", :thumbnail => "http://wiredtw.s3.amazonaws.com/wp-content/uploads/2013/03/7667395710_9bc38f4a7f_z.jpg" , :published_at => '2013-09-11', :post_ids => event_posts[8], :public => false)
  end

  def slug_sanitize(txt)
    Pinyin.t(txt, '_').gsub(/[^\w]/, "_").downcase.gsub(/__*/, '_')[0..63]
  end

end

