#encoding: utf-8  
module ApplicationHelper

  def trim(txt, length)
    half = txt.gsub(/[\p{Han}]/, '').length
    full = txt.length - half
    trimtxt = (half/2 > full) ? txt[0..length-1] : txt[0..length/2-1]
    trimtxt += '...' if (trimtxt.length < txt.length)
    trimtxt
  end

  def cap_first(txt)
    txt = txt.slice(0,1).capitalize + txt.slice(1..-1)
  end

  MOBILE_USER_AGENTS =  'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                        'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                        'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                        'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                        'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile'
  def mobile?
    agent_str = request.user_agent.to_s.downcase
    return false if agent_str =~ /ipad/
    agent_str =~ Regexp.new(MOBILE_USER_AGENTS)
  end

end
