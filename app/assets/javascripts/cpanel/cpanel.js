$('form input[type=file]').change(function() {
  var src;
  if('files' in this) {// File API supported (webkit/FF)
    var obj = this.files[0];
    src = window.URL ? window.URL.createObjectURL(obj) : window.webkitURL.createObjectURL(obj);
  } else {
    if(/fake/.test(this.value)) {
      // fallback to whatever (IE8, IE9)
    } else {
      src = this.value;
      // exploits the IE security hole
    }
  }

  // the local image!
  $('#upload_img_preview').empty().append($('<img>').attr('src', src).css({
    width : 128
  }));
});

$(".datepicker, #post_published_at").datepicker('hide');

// emphasize hot_tags
if ($("#hot_tag_ids").length > 0){
  var hot_tag_ids = $("#hot_tag_ids").attr("ids").split(',');
  $.each(hot_tag_ids, function(index, value) {
    $("#post_tag_ids_" + value).parent(".checkbox").css("color", "red");
  });
}


var kcnt = 0;
//$(".nicEdit-main").attr("tabindex", 1);
//$(".nicEdit-main").keydown(function(event) {
//  kcnt += 1;
//  console.log(kcnt);
//  //$("#form1").submit();
//});

//$(".nicEdit-main").sisyphus();

//    bkLib.onDomLoaded(function(){
//      var myEditor = new nicEditor({fullPanel : true }).panelInstance('post_content');
//      myEditor.addEvent('key', function() {
//        console.log( myEditor.instanceById('post_content').getContent() );
//      });
//    });
//
