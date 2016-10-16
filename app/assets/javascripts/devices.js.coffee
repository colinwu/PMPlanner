fields = ['#dev_notes', '#search_crm', "#search_model", "#search_sn", "#search_client_name","#search_addr1", "#search_city" ]

root = exports ? this
root.changed = false
deltaBW = exports ? this
deltaC = exports ? this
deltaBW = deltaC = 0
main_counter_changed = exports ? this
main_counter_changed = false

jQuery ->
  # begin test script
  dev_id = $("#reading_device_id").val()
  
  # end test script
  set_size_of field for field in fields
  $("#device_location").outerWidth($("#device_location").parent().width() - $(".left_field_label").outerWidth() - 10)

  $(window).resize ->
    set_size_of field for field in fields
    $("#device_location").outerWidth($("#device_location").parent().width() - $(".left_field_label").outerWidth() - 10)
  
# Detects the last device to be "checked" and makes it the target for "service history", "PM status" and "Data Entry"
  $("[id^='device_']").change (e) ->
    if $(this).is(":checked")
      $("#service_history_link").attr("href", "/devices/" + $(this).val() + "/service_history")
      $("#enter_data_link").attr("href", "/devices/" + $(this).val() + "/enter_data")
      $("#analyze_data_link").attr("href", "/devices/" + $(this).val() + "/analyze_data")
      $("#transfer_link").attr("href", "/devices/" + $(this).val() + "/transfer")

# When hovering over a part in an aggregate parts list, make the text colour blue
  $("[id^='part_list_']").hover (e) ->
    $("[id^='part_list_']").css('color', '')
    $(this).css("color", 'blue')
  
  $("[id^='part_list_']").click (e) ->
    $("[id^='part_list_']").css('background-color', '')
    $(this).css('background-color', 'pink')

  $("[id^='part_list_']").click (e) ->
    $("tr").css("background-color", "")
    $("[id^='"+$(this).text()+"']").css("background-color", 'pink')

  $('#client_name').bind('railsAutocomplete.select', (e, data) ->
    $.ajax(url: "/clients/" + data.item.id + "/get_locations.json").done (html) ->
      content = ''
      for c in html
        content += '<input type="radio" value="' + c.id + '" name="device[location_id]" id="device_location_id_' + c.id + '" /> ' + c.to_s + '<br />'
      content += '<hr>
        <fieldset><legend>New Location. Fill in all fields as best as you can.</legend>
        <span class="left_field_label">Address1</span>
        <input type="text" name="location[address1]" id="location_address1" value="" size="40" /><br />
        <span class="left_field_label">Address2</span>
        <input type="text" name="location[address2]" id="location_address2" value="" size="40" /><br />
        <span class="left_field_label">City</span>
        <input type="text" name="location[city]" id="location_city" value="" size="40" /><br />
        <span class="left_field_label">Province</span>
        <input type="text" name="location[province]" id="location_province" value="" size="2" /><br />
        <span class="left_field_label">Postal Code</span>
        <input type="text" name="location[post_code]" id="location_post_code" value="" size="7" />
        </fieldset>'
      $('#device_location').html(content)
  )

# Automatically fill in appropriate counter fields when the maintenance counters have been changed
  change_val_of = (code, diff) ->
    if code != 'TA' and code != 'CA' and code != 'MREQ' and code != 'AA'
      $("#counter_#{code}").val(Number($("#prev_#{code}").text().replace(/[^0-9]/g,'')) + diff)

# When BWTOTAL has changed ...
  $("#counter_BWTOTAL").change (e) ->
    $(e.currentTarget).css("background-color","#99ff99")
    unless main_counter_changed
      bw = JSON.parse($("#bw_hidden").text())
      color = JSON.parse($("#c_hidden").text())
      all = JSON.parse($("#all_hidden").text())
      
      deltaBW = Number($(e.currentTarget).val().replace(/[^0-9]/g,'')) - Number($("#prev_BWTOTAL").text().replace(/[^0-9]/g,''))
      if color.length > 0
        deltaC = Number($("#counter_CTOTAL").val().replace(/[^0-9]/g,'')) - Number($("#prev_CTOTAL").text().replace(/[^0-9]/g,''))
        
      change_val_of code, deltaBW for code in bw
  #     change_val_of code, deltaC for code in color
      change_val_of code, (deltaBW + deltaC) for code in all

      root.changed = true

# When CTOTAL has changed ...
  $("#counter_CTOTAL").change (e) ->
    $(e.currentTarget).css("background-color","#99ff99")
    unless main_counter_changed
      root.changed = true
      bw = JSON.parse($("#bw_hidden").text())
      color = JSON.parse($("#c_hidden").text())
      all = JSON.parse($("#all_hidden").text())
    
      deltaBW = Number($("#counter_BWTOTAL").val().replace(/[^0-9]/g,'')) - Number($("#prev_BWTOTAL").text().replace(/[^0-9]/g,''))
      deltaC = Number($(e.currentTarget).val().replace(/[^0-9]/g,'')) - Number($("#prev_CTOTAL").text().replace(/[^0-9]/g,''))
      
      change_val_of code, deltaC for code in color
      change_val_of code, (deltaBW + deltaC) for code in all
    
    
  $("#counter_TA").change (e) ->
    root.changed = true
    main_counter_changed = true
    $(e.currentTarget).css("background-color","#99ff99")
    bw = JSON.parse($("#bw_hidden").text())
    color = JSON.parse($("#c_hidden").text())
    all = JSON.parse($("#all_hidden").text())
    TA_val = Number($(e.currentTarget).val().replace(/[^0-9]/g,''))
    prev_TA_val = Number($("#prev_TA").text().replace(/[^0-9]/g,''))
    deltaBW = TA_val - prev_TA_val - deltaC
    change_val_of code, deltaBW for code in bw
    change_val_of code, (deltaBW + deltaC) for code in all
    
  $("#counter_CA").change (e) ->
    root.changed = true
    main_counter_changed = true
    $(e.currentTarget).css("background-color","#99ff99")
    bw = JSON.parse($("#bw_hidden").text())
    color = JSON.parse($("#c_hidden").text())
    all = JSON.parse($("#all_hidden").text())
  
    deltaC = Number($(e.currentTarget).val().replace(/[^0-9]/g,'')) - Number($("#prev_CA").text().replace(/[^0-9]/g,''))
    change_val_of code, deltaC for code in color
    change_val_of code, (deltaBW + deltaC) for code in all
    $("#counter_TA").change()
  
  $("#counter_MREQ").change (e) ->
    root.changed = true
    main_counter_changed = true
    $(e.currentTarget).css("background-color","#99ff99")
    bw = JSON.parse($("#bw_hidden").text())
    color = JSON.parse($("#c_hidden").text())
    all = JSON.parse($("#all_hidden").text())
    deltaBW = Number($(e.currentTarget).val()) - Number($("#prev_MREQ").text())
    change_val_of code, deltaBW for code in bw
    change_val_of code, (deltaBW + deltaC) for code in all
    
# When a form field has changed set the changed flag to true
  $("[id^='counter_']").change (e) ->
    root.changed = true

# Reset changed flag when "Save Reading" button clicked
  $("[value='Save Reading']").click (e) ->
    root.changed = false
    true
    
  $(window).on "beforeunload", (e) ->
    if root.changed
      "Are you sure?"
   
    
