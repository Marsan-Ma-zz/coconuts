//=========================================
//  Post format
//=========================================
// album
$(".album_chip").click(function(){
  $(".current").removeClass("current");
  $(this).addClass("current");
  var img = $(this).attr("img");
  $("#post_thumb").attr("src", img);
}); 

//slider
$(window).load(function() {
  // The slider being synced must be initialized first
  $('#carousel').flexslider({
  animation: "slide",
  controlNav: false,
  animationLoop: false,
  slideshow: false,
  itemWidth: 210,
  itemMargin: 5,
  asNavFor: '#slider'
  });
   
  $('#slider').flexslider({
  animation: "fade",
  controlNav: false,
  directionNav: false,
  animationLoop: false,
  slideshow: false,
  sync: "#carousel"
  });
});


