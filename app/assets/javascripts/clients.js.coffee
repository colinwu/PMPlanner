fields = ['#search_name', "#search_phone1", "#search_phone2", "#search_email","#search_notes", "#search_location" ]


jQuery ->
  set_size_of field for field in fields
  $("#device_location").outerWidth($("#device_location").parent().width() - $(".left_field_label").outerWidth() - 10)

  $(window).resize ->
    set_size_of field for field in fields
    $("#device_location").outerWidth($("#device_location").parent().width() - $(".left_field_label").outerWidth() - 10)
