class BulletsController < ApplicationController

  def index
  end

  def show
  end

  def follow
    if user_signed_in?
      bid = params[:bid].to_i
      if bullet = Bullet.find(bid)
        if (params[:act] == "follow")
          current_user.push(:collection_ids, bid) if not current_user.collection_ids.include?(bid)
        else
          current_user.pull(:collection_ids, bid) if current_user.collection_ids.include?(bid)
        end
        bullet.update_follower_count
        render :nothing => true
      end
    end
  end

end
