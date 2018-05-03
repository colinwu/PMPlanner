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
//= require_self
//= require jquery
//= require best_in_place
//= require jquery.purr
//= require best_in_place.purr
//= require jquery_ujs
//= require bootstrap
//= require jquery-ui
//= require best_in_place.jquery-ui

//= require_tree .
set_size_of = function(element) {
  var width;
  if ($(element).attr("class") === "variable-width-input") {
    $(element).outerWidth(1);
    return $(element).outerWidth("100%");
  } else {
    width = $(element).outerWidth();
    return $(element).parent().innerWidth(width);
  }
};
