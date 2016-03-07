module VendorsHelper
  def vendor_test(params)
    case params[:vendor]
      when "img"
        link_to(image_tag(params[:url], :width => "100%"), params[:link])
      when "iframe"
        content_tag(:iframe, "", :src => params[:url], :width => "100%", :height => params[:height], :frameborder => "0", :scrolling => "no")
      else
        content_tag(:iframe, "", :src => params[:vendor], :width => "100%", :height => params[:height], :frameborder => "0",:scrolling => "no")
    end
  end

  def get_note(key)
    note = Note.where(:key => key).first
    val = note ? note.value : nil
  end

end
