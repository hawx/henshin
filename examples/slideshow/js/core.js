$(document).ready(function() {
  var slide_index  = 1,
      total_slides = count_slides(),
      item_index   = 0, // list item currently shown
      total_items  = count_items();
  
  update_slide();
  toggle_contents();
  
  // j = 74
  // k = 75
  // right = 39
  // left = 37
  // space = 32
  // c = 67
  $('body').keydown(function(e) {
    switch(e.keyCode) {
      case 74: case 39: case 32:
        next_slide();
        break;
      case 75: case 37:
        previous_slide();
        break;
      case 67:
        toggle_contents();
    }
  });
  
  function slide() {
    return $('.slide:nth-child(' + slide_index + ')');
  }
  
  function count_slides() {
    return $('.slide').size();
  }
  
  function count_items() {
    if (slide().hasClass('incremental')) {
      if (slide().hasClass('bullets')) {
        items = slide().find('ul li');
        return items.size();
      }
    }
    return 0
  }
  
  function next_slide() {
    if (total_items > 0 && item_index < total_items) {
      item_index += 1;
      update_items();
    } else if (slide_index < total_slides) {
      slide_index += 1;
      update_slide();
    }
  }
  
  function previous_slide() {
    if (slide_index > 1) {
      slide_index -= 1;
      update_slide();
    }
    show_items();
  }
  
  function update_slide() {
    $('.slide').hide();
    slide().show();
    if (slide().hasClass('incremental')) {
      if (slide().hasClass('bullets')) {
        items = slide().find('ul li');
        total_items = items.size();
        items.hide();
      }
    }
  }
  
  function update_items() {
    if (slide().hasClass('bullets')) {
      slide().find('ul li:nth-child(' + item_index + ')').show();
    }
  }
  
  function show_items() {
    item_index = count_items();
    total_items = count_items();
    if (slide().hasClass('bullets')) {
      slide().find('ul li').show()
    }
  }
  
  function toggle_contents() {
    $('.contents').toggle();
  }
  
});