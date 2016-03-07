module UsersHelper
  def get_avatar(user, size=30)
    nobody = (size > 48) ? "avatar/big.png" : "avatar/normal.png"
    img = user.avatar.blank? ? nobody : (size > 48) ? user.avatar.big : user.avatar.normal
    image_tag(img, :size => "#{size}x#{size}", :id => "user_avatar")
  end
end
