$('.sponsorFlip').bind("click",function(){
  var elem = $(this);
  if(elem.data('flipped'))
  {
    elem.revertFlip();
    elem.data('flipped',false)
  }
  else
  {
    elem.flip({
      direction:'lr',
      speed: 150,
      onBefore: function(){
        elem.html(elem.siblings('.sponsorData').html());
      }
    });
    elem.height(elem.width());
    elem.data('flipped',true);
  }
});
