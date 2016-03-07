//===================================================
//  nicEdit with autosave
//===================================================
if(typeof bkLib != 'undefined') {
  var kcnt = 0;
  var myEditor;
  bkLib.onDomLoaded(function(){
    myEditor = new nicEditor({fullPanel : true }).panelInstance('post_content');
    myEditor.addEvent('focus', function() {
      //alert( myEditor.instanceById('post_content').getContent() );
      $(".nicEdit-main").attr("id", "post_editor");
      $("#post_editor").attr("tabindex", 0);
      $("#post_editor").keyup(function(event) {
        kcnt += 1;
        if (kcnt > 100) {
          console.log(kcnt);
          kcnt = 0;
          myEditor.instanceById('post_content').saveContent();
          $(".simple_form").attr("data-remote", "true");
          $('.simple_form').submit();
          $(".simple_form").removeAttr("data-remote");
        }
      });
    });
  });
  
  $("#submit_post_content").click(function() {
    myEditor.instanceById('post_content').saveContent();
    $('.simple_form').submit();
    alert("文章已儲存。");
  });
}


//===================================================
//  "Add HTML block" button
//===================================================
var nicMyhtmlOptions = {
    buttons : {
      'html' : {name : 'Insert Html', type : 'nicMyhtmlButton'}
    },iconFiles : {'html' : 'https://s3-ap-northeast-1.amazonaws.com/wired-tw/images/cpanel/add_html.gif'}

};

var nicMyhtmlButton=nicEditorAdvancedButton.extend({
      addPane: function () {
      this.addForm({
        '': { type: 'title', txt: 'Insert Html' },
        'code' : {type : 'content', 'value' : '', style : {width: '340px', height : '200px'}}
      });
    },

    submit : function(e) {
      var mycode = this.inputs['code'].value;
      this.removePane();
      this.ne.nicCommand('insertHTML', mycode );
    }

});
nicEditors.registerPlugin(nicPlugin,nicMyhtmlOptions);
