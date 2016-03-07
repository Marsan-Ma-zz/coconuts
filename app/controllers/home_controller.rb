# coding: utf-8
class HomeController < ApplicationController

  def index
    set_meta_tags :title => params[:controller], :description => "Wired News", :keywords => "Site, Login, Members"
    carousels = Note.where(:key => /home_carousel/).map(&:value)
    @banners = Post.where(:id.in => carousels)
    @news = Post.published.limit(15)
    @sponsors = get_sponsors
  end

  private

  def get_sponsors
    sponsors = [
      ['facebook','地球上最大的社群網站，還需要介紹嗎？','facebook.com'],
      #['apple', '人類史上最具傳奇性的創新電子科技產品公司。', 'apple.com'],
      ['ibm', '創新產品、商業解決方案以及商業顧問服務相關資訊', 'ibm.com'],
      ['appworks', '專注於中文網路與行動應用的天使創投', 'appworks.tw'],
      ['trendmicro', '來自台灣的雲端防毒專家,網路安全的全球領導品牌', 'trendmicro.com'],
      ['etu', '台灣本土的數據服務公司', 'etusolution.com']
    ]
      #['canon','Imaging and optical technology manufacturer.','www.canon.com']
      #['ea','The biggest computer game manufacturer.','www.ea.com'],
      #['mysql','The most popular open source database engine.','www.mysql.com'],
      #['google','The company that redefined web search.','google.com'],
      #['yahoo','The most popular network of social media portals and services.','yahoo.com'],
      #['microsoft','One of the top software companies of the world.','www.microsoft.com'],
      #['sony','A global multibillion electronics and entertainment company ','sony.com'],
      #['hp','One of the biggest computer manufacturers.','hp.com'],
      #['adobe','The leading software developer targeted at web designers and developers.','adobe.com'],
      #['dell','One of the biggest computer developers and assemblers.','dell.com'],
      #['ebay','The biggest online auction and shopping websites.','ebay.com'],
      #['digg','One of the most popular web 2.0 social networks.','www.digg.com'],
      #['cisco','The biggest networking and communications technology manufacturer.','cisco.com'],
      #['vimeo','A popular video-centric social networking site.','vimeo.com'],
  end
  
end
