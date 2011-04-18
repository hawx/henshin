$(document).ready(function() {
  var current_slide = 1,
      total_slides = $('.slide').size(),
      current_item = 0, // list item currently shown
      total_items = 0;
  
  update_slide();
  
  
  // j = 74
  // k = 75
  // right = 39
  // left = 37
  // space = 32
  $('body').keydown(function(e) {
    switch(e.keyCode) {
      case 74: case 39: case 32:
        next_slide();
        break;
      case 75: case 37:
        previous_slide();
    }
  });
  
  
  function next_slide() {
    if (total_items > 0 && current_item < total_items) {
      current_item += 1;
      update_items();
    } else if (current_slide < total_slides) {
      current_slide += 1;
      update_slide();
    }
  }
  
  function previous_slide() {
    current_item = 0;
    total_items = 0;
    if (current_slide > 1) {
      current_slide -= 1;
      update_slide();
    }
  }
  
  function update_slide() {
    $('.slide').hide();
    var slide = $('.slide:nth-child('+current_slide+')');
    slide.show();
    if (slide.hasClass('incremental')) {
      if (slide.hasClass('bullets')) {
        items = slide.find('ul li');
        total_items = items.size();
        items.hide();
      }
    }
  }
  
  function update_items() {
    slide = $('.slide:nth-child('+current_slide+')');
    if (slide.hasClass('bullets')) {
      slide.find('ul li:nth-child('+current_item+')').show();
    }
  }
  
});