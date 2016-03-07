function follow(act, bid) {
  $.ajax({
    type: 'POST',
    url: "/bullets/follow" ,
    data: {
      act : act,
      bid : bid
    }
  }); 
}

function login_first() {
  alert("抱歉，這個功能需要您先登入。\nSorry, you have to login to do this.");
}

$(document).on('click', ".unfollow", function () {
  $(this).attr("class", "follow");
  cnt = $(this).siblings(".count");
  cnt.text(parseInt(cnt.text()) + 1);
  follow('follow', $(this).attr("bid"));
});

$(document).on('click', ".follow", function () {
  $(this).attr("class", "unfollow");
  cnt = $(this).siblings(".count");
  cnt.text(parseInt(cnt.text()) - 1);
  follow('unfollow', $(this).attr("bid"));
});
