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

if (navigator.geolocation) {
  var timeoutVal = 10 * 1000 * 1000;
  var age = 1000 * 600
  navigator.geolocation.getCurrentPosition(
    displayPosition, 
    displayError,
    { enableHighAccuracy: true, timeout: timeoutVal, maximumAge: age }
  );
}
else {
  alert("Geolocation is not supported by this browser");
}

function displayPosition(position) {
  console.log("Latitude: " + position.coords.latitude + ", Longitude: " + position.coords.longitude);
//   var data = "lat=" + position.coords.latitude + "&long=" + position.coords.longitude
  var data = "lat=45.3517699&long=-75.6523359"
  $.ajax({
    url: '/technicians/remember_location',
    data: data,
    type: 'get'
  })
  
  .done(function(response) {
    console.log("data successfully sent back to rails app")
  })
  
  .fail(function(error) {
    console.log("Save error: "+error);
  });
}

function displayError(error) {
  var errors = { 
    1: 'Permission denied',
    2: 'Position unavailable',
    3: 'Request timeout'
  };
  alert("Error: " + errors[error.code]);
}
