// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= notrequire jquery-ui
//= notrequire jquery_ujs
//= notrequire_tree ./front/
//= require social-share-button
//= require ./theme/organictabs.jquery
//= require ./theme/jquery.flexslider
//= require ./theme/jquery.ui.widget
//= require ./theme/jquery.sausage
//= require ./theme/jquery.color
//= require ./theme/jquery.equalheights
//= require ./theme/lightbox-2.6.min
//= require ./theme/script
//= require ./theme/plugins
//= require ./theme/main
//= require ./theme/extra
//= require ./theme/bullet
//= require ./theme/ad

//for GooglePlus Like
(function() {
  var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
  po.src = 'https://apis.google.com/js/plusone.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
})();

//CSRF problem, http://stackoverflow.com/questions/7203304/warning-cant-verify-csrf-token-authenticity-rails
$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});


// facebook script
(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=1437203073165806";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));

//$("img").lazyload({ 
//  threshold : 200, 
//  effect : "fadeIn"
//});


// GQ Ad
$.ajax({
  type: "get",
  async: true,
  url: "http://www.gq.com.tw/inc/api_AD300x250_WIRED.asp",
  dataType: "jsonp",
  jsonp: "callback",
  jsonpCallback: 'AD_Handler', 
  success: function (res) {
    $("#gq_ad_300x250").html(res.AD_Msg);
    eval(res.AD_Script);
  },
  error: function () {
    $("#gq_ad_300x250").html("");
  }
});
