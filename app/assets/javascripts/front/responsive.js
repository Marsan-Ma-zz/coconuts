//===================================
//  Home Elegant Accordion Slideshow
//===================================
$('#slideshow li').click(function(e) {
  window.open($(this).attr("href"), '_blank');
});
$('#slideshow ul').eAccordion({
  easing: 'swing',
  delay: 9000,
  animationTime: 500,
  expandedWidth: '85%'     //# Width of the expanded slide
});


//===================================
//  Sticky navbar
//===================================
var aboveHeight = $('#sticky_navbar').position().top;
$(window).scroll(function(){
  //console.log("[ScrollTop] = " + $(window).scrollTop() + "/" + aboveHeight);
  if ($(window).scrollTop() > aboveHeight){
    //$('#sticky_navbar').addClass('sticky_nav');
    //$('#nav_logo').css('display', 'block');
    //$('#nav_logo').stop(true, true).animate({width: '0px'}, duration);
  } else {
    //$('#sticky_navbar').removeClass('sticky_nav');
    //$('#nav_logo').css('display', 'none');
    //$('#nav_logo').stop(true, true).animate({width: '150px'}, duration);
  }
});

//===================================
//  Footer Sponsor Flipwall  
//===================================
$('.sponsorFlip').height($(".sponsorFlip").width());

//===================================
//  Responsive: on window-size changed    
//===================================
var waitForWindowResize = (function () {
  var timers = {};
  return function (callback, ms, uniqueId) {
    if (!uniqueId) {
      uniqueId = "Don't call this twice without a uniqueId";
    }
    if (timers[uniqueId]) {
      clearTimeout (timers[uniqueId]);
    }
    timers[uniqueId] = setTimeout(callback, ms);
  };
})();

$(window).resize(function () {
  waitForWindowResize(function(){
    $('.sponsorFlip').height($(".sponsorFlip").width());  //for sponsor flipwall
    aboveHeight = $('#sticky_navbar').position().top;     //for sticky navbar position
  }, 500, "window_resizeing");
});


//===================================
//  fix iframe ignoring z-index and cover sticky-navbar
//===================================
$('iframe').each(function() {
  url = $(this).attr("src")
  $(this).attr("src",url+"?wmode=transparent")
});

