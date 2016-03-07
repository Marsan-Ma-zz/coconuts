		// Fixed menu on scroll
		var $ = jQuery.noConflict();
		$("document").ready(function(){
		
			$(window).scroll(function () {
				if ($(this).scrollTop() > 160) {
					$('.header-container').addClass("f-nav");
				} else {
					$('.header-container').removeClass("f-nav");
				}
			});

		});
		
		//FlexSlider 2
		  $(window).load(function() {
			//$('.flexslider').flexslider({
      $('#home_banner').flexslider({
			touch: true,
			directionNav: true,
			});
		  });
		  
		  //Horizontal Subnav w/ CSS & jQuery
		  $(document).ready(function() {
			$("ul#topnav li").hover(function() { //Hover over event on list item
				$(this).css({ 'background' : '#E67E22'}); //Add background color + image on hovered list item
				$(this).find("span").show(); //Show the subnav
			} , function() { //on hover out...
				$(this).css({ 'background' : 'none'}); //Ditch the background
				$(this).find("span").hide(); //Hide the subnav
			});
//			$("ul#topnav li > a").hover(function() {
//				$(this).css({ 'color' : '#000000'}); 
//			}, function() { //on hover out...
//				$(this).css({ 'color' : '#ffffff'}); //Ditch the text color
//			});
		});
		
		//organicTabs
		$(function() {
    
            $("#post-rank").organicTabs();
    
        });
		
//SCROLL FUNCTION

var jump=function(e)
{
       //prevent the "normal" behaviour which would be a "hard" jump
       e.preventDefault();
       //Get the target
       var target = $(this).attr("href");
       //perform animated scrolling
       $('html,body').animate(
       {
               //get top-position of target-element and set it as scroll target
               scrollTop: $(target).offset().top
       //scrolldelay: 1 seconds
       },1000,function()
       {
               //attach the hash (#jumptarget) to the pageurl
               //location.hash = target;
       });

}

$(document).ready(function()
{
       $('a[href*=#]').bind("click", jump);
       return false;
});

// Cross-page “scroll to anchor” effect in jQuery by I am Sisar
// <a href=”foo.html?s=bar”>click me</a>
// the scrolling animation
function goToByScroll(id){
$('html,body').animate({scrollTop: $('#'+id).offset().top }, 'slow')
return false;
}

// get the destination anchor element id from the url param “s” with some regex
// and store it as an associative array
function getUrlVars() {
var vars = {};
var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
vars[key] = value;
});
return vars;
}

var anchor = getUrlVars()["s"];

// if a param “s” is found, call the animation function to the correspondent
// element id when the document is ready, with some delay
$(function(){
if(anchor) {
setTimeout ("goToByScroll(anchor)" , 1000);
};
})


//SCROLL TO TOP FUNCTION

$(function () { // run this code on page load (AKA DOM load)
 
	/* set variables locally for increased performance */
	var scroll_timer;
	var displayed = false;
	var $message = $('#message a');
	var $window = $(window);
	var top = $(document.body).children(0).position().top;
 
	/* react to scroll event on window */
	$window.scroll(function () {
		window.clearTimeout(scroll_timer);
		scroll_timer = window.setTimeout(function () { // use a timer for performance
			if($window.scrollTop() <= top) // hide if at the top of the page
			{
				displayed = false;
				$message.fadeOut(500);
			}
			else if(displayed == false) // show if scrolling down
			{
				displayed = true;
				$message.stop(true, true).show().click(function () { $message.fadeOut(500); });
			}
		}, 100);
	});
});

// EqualHeights
$(document).ready(function(){
        $('.post-list.equal').each(function(){    
            var highestBox = 0;
            $('.post', this).each(function(){
            
                if($(this).height() > highestBox) 
                   highestBox = $(this).height(); 
            });  
            $('.post',this).height(highestBox);    
    });    
});

//jQuery Smooth Animated Search Field
$(function(){

    var input = $('input#s');
    var divInput = $('div.input');
    var width = divInput.width();
    var outerWidth = divInput.parent().width() - (divInput.outerWidth() - width) - 28;
    var submit = $('#searchSubmit');
    var txt = input.val();
    
    input.bind('focus', function() {
        if(input.val() === txt) {
            input.val('');
        }
        $(this).animate({color: '#000'}, 300); // text color
        $(this).parent().animate({
            width: outerWidth + 'px',
            backgroundColor: '#fff', // background color
            paddingRight: '43px'
        }, 300, function() {
            if(!(input.val() === '' || input.val() === txt)) {
                if(!($.browser.msie && $.browser.version < 9)) {
                    submit.fadeIn(300);
                } else {
                    submit.css({display: 'block'});
                }
            }
        }).addClass('focus');
    }).bind('blur', function() {
        $(this).animate({color: '#b4bdc4'}, 300); // text color
        $(this).parent().animate({
            width: width + 'px',
            backgroundColor: '#e8edf1', // background color
            paddingRight: '15px'
        }, 300, function() {
            if(input.val() === '') {
                input.val(txt)
            }
        }).removeClass('focus');
        if(!($.browser.msie && $.browser.version < 9)) {
            submit.fadeOut(100);
        } else {
            submit.css({display: 'none'});
        }
    }).keyup(function() {
        if(input.val() === '') {
            if(!($.browser.msie && $.browser.version < 9)) {
                submit.fadeOut(300);
            } else {
                submit.css({display: 'none'});
            }
        } else {
            if(!($.browser.msie && $.browser.version < 9)) {
                submit.fadeIn(300);
            } else {
                submit.css({display: 'block'});
            }
        }
    });
});
