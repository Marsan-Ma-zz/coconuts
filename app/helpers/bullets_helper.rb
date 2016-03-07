#encoding: utf-8
module BulletsHelper
  def bullet_source(txt)
    case txt
      when 'bnext' then "數位時代"
      when 'inside' then "Inside"
      when 'techorange' then "科技橘報"
      when 'techbang' then "T客邦"
      when '36kr' then "36氪"
      when 'pansci' then "汎科學"
      when 'tech2ipo' then "創見"
      when 'stupid77' then "三十而慄"
      when 'cyzone' then "創業吧"
      when 'ifanr' then "愛范兒"
      when 'huxiu' then "虎嗅"
      when 'mr6'  then "MR6"
      when 'briian'  then "重灌狂人"
      when '199it'  then "199IT"
      when 'soft4fun'  then "硬是要學"
      when 'wiredtw'  then "WIRED"
      when 'bukop'  then "不靠譜"
      when 'mmdays'  then "MMDAYS"
    end
  end

  def sort_select(title, sort, params, lang="zh")
    path = techtrend_index_path(:sort => sort, :lang => lang)
    if ((params[:sort] == sort) && (params[:lang] == lang))
      content_tag(:option, title, :selected => "selected", :value => path)
    else
      content_tag(:option, title, :value => path)
    end
  end

end
