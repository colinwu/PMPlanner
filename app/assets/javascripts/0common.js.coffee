jQuery ->
  $("#reading_taken_at").datepicker({
    dateFormat: 'M d, yy',
  })

  $("#first_visit").datepicker({
    dateFormat: 'M d, yy',
  })
  
  $.datepicker.setDefaults({
    dateFormat: "yy-mm-dd"
  })
  
  $("body").css({"cursor": "default"})
  $("a").click ->
    $("body").css({"cursor": "wait"})

  $("input[type='submit']").click ->
    $("body").css({"cursor": "wait"})

  $("input[readonly!='readonly']").focus (e) ->
    $(e.currentTarget).effect('highlight',500)

  $("textarea[readonly!='readonly']").focus (e) ->
    $(e.currentTarget).effect('highlight',500)

  # Activating Best In Place 
  jQuery(".best_in_place").best_in_place()

  $("#tech_id").change (e) ->
    $("#tech_select").submit()
   
