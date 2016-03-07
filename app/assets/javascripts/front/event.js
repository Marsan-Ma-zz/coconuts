$(".event_chapter_handler").not("h3").hover(function () {
  var t = $(this).attr("target"); 
  $(".chapter_brief").each(function() {
    $(this).hide();
  });
  $("#" + t).show();
});
