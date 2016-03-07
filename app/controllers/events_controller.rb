# coding: utf-8
class EventsController < ApplicationController
  layout "full_custum"

  def index
    set_meta_tags :title => "Events", :description => "Wired Event List", :keywords => "Wired, Event"
  end

  def show
    case params[:id]
      when "open_knowledge"
        @sponsors = get_sponsors
        set_meta_tags :title => "Open-Knowledge", :description => "Wired 共同發起 Open-Knowledge", :keywords => "Open-Knowledge, 開放知識"
      when "big_data_magzine"
        @mp_class = 'insider'
        if (current_user && current_user.admin?)
          @features = Feature.where(:slug => /big_data_part_/).asc(:slug)
        else
          @features = Feature.where(:slug => /big_data_part_/, :published_at.lt => Time.now).asc(:slug)
        end
        set_meta_tags :title => "Big-Data Magazine", :description => "Wired Big-Data Magazine 大數據特刊", :keywords => "bigdata, data mining, data analysis, 資料分析, 海量數據"
      when "2013_spring_forum"
        set_meta_tags :title => "Big-Data Forum", :description => "Wired Big-Data Forum 大數據講座", :keywords => "bigdata, data mining, data analysis, 資料分析, 海量數據"
    end
    if params[:id]
      render "events/#{params[:id]}"
    else
      redirect_to :index
    end
  end

  private
  def get_sponsors
    sponsors = [
      # 政府法人
      ["nsc", "推動整體科技發展，調查科技研究發展動態，支援學術研究。", "web1.nsc.gov.tw", "國科會"],
      ["itri", "自1973年孫運璿先生創辦以來，以工業技術推動台灣工業的發展，引領經濟起飛為目標。", "itri.org.tw", "工研院"],
      ["tier", "辜振甫先生創辦之獨立學術研究機構，積極從事國內、外經濟及產業經濟之研究", "www.tier.org.tw", "台灣經濟研究院"],
      ["topology", "拓墣產研從事科技產業趨勢研究，擁有半導體、光電、通訊、IA、區域市場等研究中心", "www.topology.com.tw", "拓璞產業研究所"],
      ["tdc", "台灣創意設計中心，主要任務為提升設計人才原創能力、促進國際設計交流、加強產業市場競爭力並奠定企業發展自有品牌基礎", "www.tdc.org.tw", ">台灣創意設計中心"],
      ["ideas", "資策會創辦，以「創新、創意、創業、創投」為主訴求。", "ideas.org.tw", "資策會創新發現誌"],
      ["pansci", "由台灣數位文化協會(ADCT)成立，將高深龐雜的科學發展重新放置回台灣公共論壇中", "pansci.tw", "泛科學"],

      # 公司機構 
      ["ibm", "創新產品、商業解決方案以及商業顧問服務相關資訊", "ibm.com", "IBM"],
      ["trendmicro", "來自台灣的雲端防毒專家,是網路安全的全球領導品牌", "trendmicro.com", "TrendMicro"],
      ["appworks",'專注於中文網路與行動應用的超級天使創投','appworks.tw', "AppWorks"],
      #["engadget", "消費電子產品的流行科技網誌與播客", "cool3c.com", "Engadget"],
      ["nvesto", "視覺化圖表及自選個股日報讓您快速掌握技術面、籌碼面、新聞、財報等專業股市資訊", "nvesto.com", "Nvesto"],

      # 學者專家
      ["mrjamie", "之初創投合夥人，透過育成計畫，幫助早期團隊創業，推動華文網路發展", "mrjamie.cc", "Mr.Jamie"],
      ["jollen",'活躍於兩岸的開放軟體與行動應用顧問','jollen.org', "Jollen"],
      ["vista", '曾任《數位時代》主編，目前服務於行動生活產業。關注網路、媒體、科技產業脈動', 'blog.vista.tw', "Vista"],
      ["fred", '悠遊於軟體與網路超過 20 年，目前為精誠集團擬定數據價值策略。', 'fredbigdata.blogspot.com', 'Fred'] #,
      #["kenni", '知名網路媒體人，歷任：博客邦總編，世新大學講師、數位時代專欄作家、癮科技總編等。', '', 'Kennu']
    ]
  end

  def big_data_part_title(num)
    titles = ["PART 1 : EXABYTE REVOLUTION", "PART 2 : Next Big Business", "PART 3 : Mr.Big", "PART 4 : Big Thinking", 
              "PART 5 : FUTURE: Hadoop", "PART 6 : BIG INSIGHTS", "PART 7 : UNLEASHING INNOVATION", "PART 8 : SMART CITY, NEW LIFE"]
    titles[num]
  end

  def get_event_chapters(event_data)
    chapter_ids = event_data.map{|i| i[1][0] }
    chapters = Post.where(:id.in => chapter_ids).asc(:slug)
  end
end
