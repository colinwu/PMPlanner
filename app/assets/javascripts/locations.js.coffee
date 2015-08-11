fields = ["#search_client_name", "#search_city", "#search_address1", "#search_address2", "#search_province", "#search_post_code", "#search_loc_notes" ]

jQuery ->
  set_size_of field for field in fields

  $(window).resize ->
    set_size_of field for field in fields