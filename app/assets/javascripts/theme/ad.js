window._ttf = window._ttf || []
                  ,doc = window.top.document
                  ,_tt_slot = '#post_body > br, #post_body > div > p, #post_body > p'
                  ,_tt_check = doc.querySelectorAll(_tt_slot).length
                  ,_tt_i = 0;
        if (_tt_check <= 3) {
                  _tt_i = 2;
        }
        _ttf.push({
                  pid: 22765
                  ,lang: 'cn'
                  ,slot: _tt_slot
                  ,format: 'inread'
                  ,minSlot: 0
                  ,filter: function () {_tt_i++; return _tt_i > 2;}
        });
        (function(d){
                  var js, s = d.getElementsByTagName('script')[0];
                  js = d.createElement('script'); js.async = true;
                  js.src = "http://cdn.teads.tv/js/all-v1.js";
                  s.parentNode.insertBefore(js, s);
        })(window.document);