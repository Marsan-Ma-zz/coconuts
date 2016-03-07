//===========================================
//  prevent meta-status & multi-launched jobs
//===========================================
var jobQueue = (function () {
  var timers = {};
  return function (callback, ms, uniqueId) {
    if (!uniqueId) {
      uniqueId = "Don't call this twice without a uniqueId";
    }
    if (callback == null) {
      clearTimeout (timers[uniqueId]);
    } else {  
      if (timers[uniqueId]) {
        clearTimeout (timers[uniqueId]);
      }
      timers[uniqueId] = setTimeout(callback, ms);
    }
  };
})();

//===========================================
//  show sub_nav while hover navbar
//===========================================
var nav_flag = false; //prevent glitch
$("#sticky_navbar_wrap").hover(function() {
  nav_flag = true;
});

$("#sticky_navbar_wrap").mouseleave(function() {
  nav_flag = false;
  jobQueue(function(){
    if (!nav_flag) {wrap_nav();}
  }, 1500, "wrap_navbar");
});

$("#sticky_navbar_wrap").click(function(){
  nav_flag = true;
  if (nav_flag) {expand_nav();}
});

function expand_nav() {
  var expand_width = ($("body").width() >= 510) ? '80px' : '125px';
  $("#header_top").stop(true, true).animate({
    paddingTop: expand_width
  }, 200);
  $("#sub_nav, .sub_inner").stop(true, true).animate({
    opacity: 1,
    height: '30px'
  }, 200);
};

function wrap_nav() {
  $("#sub_nav, .sub_inner").stop(true, true).animate({
    opacity: 0,
    height: '0px'
  }, 200);
  $("#header_top").stop(true, true).animate({
    paddingTop: '50px'
  }, 200);
  if ($("body").width() < 510) {
    wrap_mobile_nav();
  }
};

//----- Mobile Navbar -----
function expand_mobile_nav() {
  $("#main_nav").stop(true, true).animate({height: '95px'}, 200);
  $(".nav_cats a, .mobile_divider").show();
};

function wrap_mobile_nav() {
  $("#main_nav").stop(true, true).animate({height: '30px'}, 200);
  $(".nav_cats a, .mobile_divider").fadeOut(0);
};

$("#mobile_cats_expand").hover(function () {expand_mobile_nav();});

//===========================================
//  select sub_nav inner
//===========================================
//initial hide all
$(document).ready(function() {
  $(".sub_inner").fadeOut();
});
//show only selected
$("#main_nav li").not(".nav_divider").click(function() {
  var t = "#" + $(this).attr("target");
  $("#sub_nav ul").fadeOut(0, function() {
    $(t).show();
  });
  $("#main_nav li").removeClass("nav_active");
  $(this).addClass("nav_active");
});

//===========================================
//  Recover after window resize
//===========================================
$(window).resize(function () {
  jobQueue(function(){
    //hide sub_nav
    $("#sub_nav").stop(true, true).animate({
      opacity: 0,
      height: '0'
    }, 200);
    //recover main_nav from mobile
    $("#main_nav").stop(true, true).animate({
      height: '30px'
    }, 200);
    console.log($("body").width());
    if($("body").width() >= 510) {
      $(".nav_cats a").show();
      $(".mobile_divider").fadeOut(0);
    } else {
      $(".nav_cats a, .mobile_divider").fadeOut(0);
    }
    mobile_cats = false;
  }, 500, "window_resizeing");
});

