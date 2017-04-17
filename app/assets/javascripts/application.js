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
//= require jquery-ui
//= require best_in_place.jquery-ui
//= require autocomplete-rails
//= require jquery.datetimepicker
//= require_tree .

set_size_of = function(e) {
  $(e).outerWidth(1);
  console.log($(e).parent().innerWidth());
  return($(e).outerWidth($(e).parent().innerWidth()));
};
