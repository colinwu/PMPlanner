fields = ['#dev_notes', '#search_crm', "#search_model", "#search_sn", "#search_client_name","#search_addr1", "#search_city" ]

jQuery ->
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
   