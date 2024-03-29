fields = ['#dev_notes', '#search_crm', "#search_model", "#search_sn", "#search_client_name","#search_addr1", "#search_city", "#model_group_name", "#pm_code_name", "#parts_for_pm_choice", "#part_name", "#part_description", "#parts_for_pm_quantity" ]

root = exports ? this
root.changed = false
deltaBW = exports ? this
deltaC = exports ? this
deltaBW = deltaC = 0
main_counter_changed = exports ? this
main_counter_changed = false

jQuery ->    
  # retrieve the current device's ID #
  dev_id = $("#reading_device_id").val()
  
  # for 'edit' and 'new' retrieve list of model names to be used for autocomplete
  url = document.documentURI
  mfp_models = []
  mfp_model_id = {}
  if url.match(/\/devices\/new$/) || url.match(/\/devices\/\d+\/edit$/)
    $.getJSON '/models', (result) ->
      $("#device_model_nm").hide()
      for m in result
        mfp_models.push(m.nm)
        mfp_model_id[m.nm] = m.id
      $("#device_model_nm").autocomplete({ source: mfp_models })
      $("#device_model_nm").show()
  
  # if url.match(/\/devices\/new$/)
  #   all_ids = JSON.parse($("#all_dev_ids_hidden").text())
  #   $("#device_crm_object_id").autocomplete({ source: all_ids})

  # Set the size of the input field to be the same as the enclosing element 
  # (usually this is a table cell) when the browser window is resized
  set_size_of field for field in $("[class$='width-input']")
  
#   $("#device_location").outerWidth($("#device_location").parent().width() - $(".left_field_label").outerWidth() - 10)

#   $(window).resize ->
#     set_size_of field for field in $("[class$='width-input']")
#     $("#device_location").outerWidth($("#device_location").parent().width() - $(".left_field_label").outerWidth() - 10)
  
# Detects the last device to be "checked" and makes it the target for "service history", "PM status" and "Data Entry"
  $("[id^='device_']").change (e) ->
    if $(this).is(":checked")
      $("#service_history_menu").attr("href", "/devices/" + $(this).val() + "/service_history")
      $("#enter_data_menu").attr("href", "/devices/" + $(this).val() + "/enter_data")
      $("#analyze_data_menu").attr("href", "/devices/" + $(this).val() + "/analyze_data")
      $("#transfer_menu").attr("href", "/devices/" + $(this).val() + "/transfer")

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

# Use autocomplete to help select the right customer name.

  clients = []
  client_ids = {}
  if url.match(/\/devices\/new$/) || url.match(/\/devices\/\d+\/edit$/)
    $.getJSON '/clients', (result) ->
      for c in result
        clients.push(c.name)
        client_ids[c.name] = c.id
      $("#client_name").autocomplete({ 
          source: clients, 
          minLength: 3,
          select: (e, ui) ->
            $('#device_client_id').val("#{client_ids[ui.item.value]}")
            $.getJSON '/clients/' + client_ids[ui.item.value] + '/get_locations', (result) ->
              content = ''
              for c in result
                content += '<input type="radio" value="' + c.id + '" name="device[location_id]" id="device_location_id_' + c.id + '" /> ' + '<a href="/locations/' + c.id + '/edit">' + c.to_s + '</a><br />'
              content += '<br />
                <fieldset><legend>New Location. Fill in all fields as best as you can.</legend>
                <label class="control-label col-sm-2" for="location_address1">Address line 1</label>
                <div class="col-sm-10">
                <input type="text" name="location[address1]" id="location_address1" value="" class="form-control input-sm" />
                </div>
                <label class="control-label col-sm-2" for="location_address2">Address line 2</label>
                <div class="col-sm-10">
                <input type="text" name="location[address2]" id="location_address2" value="" class="form-control input-sm" />
                </div>
                <label class="control-label col-sm-2" for="location_city">City</label>
                <div class="col-sm-10">
                <input type="text" name="location[city]" id="location_city" value="" class="form-control input-sm" />
                </div>
                <label class="control-label col-sm-2" for="location_province">Province</label>
                <div class="col-sm-10">
                <select name="location[province]" id="location_province" class="form-control input-sm"><option value=""></option>
                <option value="AB">Alberta</option>
                <option value="BC">BC</option>
                <option value="MB">Manitoba</option>
                <option value="NB">New Brunswick</option>
                <option value="NF">Newfoundland</option>
                <option value="NS">Nova Scotia</option>
                <option value="ON">Ontario</option>
                <option value="PEI">PEI</option>
                <option value="QC">Quebec</option>
                <option value="SK">Sask</option></select>
                </div>
                <label class="control-label col-sm-2" for="location_post_code">Postal Code</label>
                <div class="col-sm-10">
                <input type="text" name="location[post_code]" id="location_post_code" value="" class="form-control input-sm" />
                </div>
                </fieldset>'
              $('#device_location').html(content)
       })
      
  # $('#client_name').bind('railsAutocomplete.select', (e, data) ->
  #   $.ajax(url: "/clients/" + data.item.id + "/get_locations.json").done (html) ->
  #     content = ''
  #     for c in html
  #       content += '<input type="radio" value="' + c.id + '" name="device[location_id]" id="device_location_id_' + c.id + '" /> ' + '<a href="/locations/' + c.id + '/edit">' + c.to_s + '</a><br />'
  #     content += '<br />
  #       <fieldset><legend>New Location. Fill in all fields as best as you can.</legend>
  #       <label class="control-label col-sm-2" for="location_address1">Address line 1</label>
  #       <div class="col-sm-10">
  #       <input type="text" name="location[address1]" id="location_address1" value="" class="form-control input-sm" />
  #       </div>
  #       <label class="control-label col-sm-2" for="location_address2">Address line 2</label>
  #       <div class="col-sm-10">
  #       <input type="text" name="location[address2]" id="location_address2" value="" class="form-control input-sm" />
  #       </div>
  #       <label class="control-label col-sm-2" for="location_city">City</label>
  #       <div class="col-sm-10">
  #       <input type="text" name="location[city]" id="location_city" value="" class="form-control input-sm" />
  #       </div>
  #       <label class="control-label col-sm-2" for="location_province">Province</label>
  #       <div class="col-sm-10">
  #       <select name="location[province]" id="location_province" class="form-control input-sm"><option value=""></option>
  #       <option value="AB">Alberta</option>
  #       <option value="BC">BC</option>
  #       <option value="MB">Manitoba</option>
  #       <option value="NB">New Brunswick</option>
  #       <option value="NF">Newfoundland</option>
  #       <option value="NS">Nova Scotia</option>
  #       <option value="ON">Ontario</option>
  #       <option value="PEI">PEI</option>
  #       <option value="QC">Quebec</option>
  #       <option value="SK">Sask</option></select>
  #       </div>
  #       <label class="control-label col-sm-2" for="location_post_code">Postal Code</label>
  #       <div class="col-sm-10">
  #       <input type="text" name="location[post_code]" id="location_post_code" value="" class="form-control input-sm" />
  #       </div>
  #       </fieldset>'
  #     $('#device_location').html(content)
  # )

# Automatically fill in appropriate counter fields when the maintenance counters have been changed
  change_val_of = (code, diff) ->
    if code != 'TA' and code != 'CA' and code != 'MREQ' and code != 'AA' and code != 'BWTOTAL' and code != 'CTOTAL'
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
    deltaBW = Number($("#counter_MREQ").val()) - Number($("#prev_MREQ").text())
    change_val_of code, deltaBW for code in bw
    change_val_of code, (deltaBW + deltaC) for code in all

  $("#device_team_id").change (e) ->
    team_id = $(e.currentTarget).val()
    $("#client_name").attr('data-autocomplete',"/devices/autocomplete_client_name?team_id=#{team_id}")
    $.getJSON "/teams/#{team_id}/manager", (result) ->
      $("#manager").val("#{result.first_name} #{result.last_name}")
      return true
    $.getJSON "/teams/#{team_id}/techs", (result) ->
      techList = []
      for tech in result
        techList.push("<option value='#{tech.id}'>#{tech.first_name} #{tech.last_name}</option>")
      optionStr = techList.join("\n")
      $("#device_primary_tech_id").html(optionStr)
      $("#device_backup_tech_id").html(optionStr)
      return true
    
  $("#device_model_nm").focusout (e) ->
    $("#device_model_id").val(mfp_model_id[$(e.currentTarget).val()])
      
# When a form field has changed set the changed flag to true
  $("[id^='counter_']").change (e) ->
    root.changed = true

# Reset changed flag when "Save Reading" button clicked

  $("#counter_form").submit (e) ->
    if ($("#counter_MREQ").val() != undefined) # This is a BW machine that uses MREQ
      bwt = $("#counter_BWTOTAL").val().replace(/,/g, '')
      ta = $("#counter_MREQ").val().replace(/,/g,'')
      console.log("An older BW machine.")
      if ((ta.length == 0 || isNaN(ta)) || (bwt.length == 0 || isNaN(bwt)))
        alert("You must enter a value for MREQ and TotBW.")
        $("body").css({"cursor": "default"})
        return false
    else if ($("#counter_CA").val() == undefined && $("#counter_TA").val() != undefined) # a newer BW machine that uses TA, DK, VK
      ta = $("#counter_TA").val().replace(/,/g,'')
      bwt = $("#counter_BWTOTAL").val().replace(/,/g, '')
      console.log("A newer BW machine.")
      if ((ta.length == 0 || isNaN(ta)) || (bwt.length == 0 || isNaN(bwt)))
        alert ("You must enter a value for TotBW and TA.")
        $("body").css({"cursor": "default"})
        return false
    else   # a colour machine 
      console.log("Colour machine.")
      bwt = $("#counter_BWTOTAL").val().replace(/,/g, '')
      ct = $("#counter_CTOTAL").val().replace(/,/g, '')
      ta = $("#counter_TA").val().replace(/,/g, '')
      ca = $("#counter_CA").val().replace(/,/g, '')
      if ((bwt.length == 0 || isNaN(bwt)) || (ct.length == 0 || isNaN(ct)) || (ta.length == 0 || isNaN(ta)) || (ca.length == 0 || isNaN(ca)))
        alert("Please ensure you have entered values for each of 'TotBW', 'TotC', 'TA' and 'CA'")
        $("body").css({"cursor": "default"})
        return false
  
    root.changed = false
    true
    
  $(window).on "beforeunload", (e) ->
    if root.changed
      e.returnValue = "There is unsaved data. Are you sure you want to leave this page?"
   
    
