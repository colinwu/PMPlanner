jQuery ->
# pre-fetch list of model group names and PM Code names
  groupNames = []
  groupIDs = {}
  codeNames = []
  url = document.documentURI
  if url.match(/\/models\/new$/) || url.match(/\/models\/\d+\/edit$/)
    $("#model_group").hide()
    $.getJSON "/model_groups", (result) ->
      for mg in result
        gn = mg.model_group.name
        groupIDs[gn] = mg.model_group.id
        groupNames.push(gn)
      $("#model_group").autocomplete({ source: groupNames })
      $("#model_group").show()
      return true
    $.getJSON "/pm_codes", (result) ->
      for item in result
        codeNames.push(item.pm_code.name)
      return true
  
  $("#model_group").focusout (e) ->
    mg = $(e.currentTarget).val()
    to_show = ['BWTOTAL', 'CTOTAL']
    to_hide = []
    if mg.length > 0 and groupNames.indexOf(mg) != -1
      targetValue = {}
      targetSec = {}
      targetLbl = {}
      $("[id$='_field']").show()
      $.getJSON "/model_groups/#{groupIDs[mg]}/get_targets", (result) ->
        # build list of codes that should remain visible
        for item in result
          target = item.model_target
          targetValue[target.maint_code] = target.target
          targetSec[target.maint_code] = target.section
          targetLbl[target.maint_code] = target.label
          to_show.push(target.maint_code)

        # build list of codes to hide and actually hide them
        codeNames.forEach (c) ->
          if to_show.indexOf(c) == -1 or targetValue[c] == 0
            to_hide.push(c)
            $("##{c}_field").hide()
            
          # now show the target values
        to_show.forEach (c) ->
          $("#pm_code_#{c}").val(targetValue[c])
          $("#section_#{c}").val(targetSec[c])
          $("#label_#{c}").val(targetLbl[c])
        return true
        
  $("#pm_code_DC").change (e) ->
    val = $(e.currentTarget).val()
    $("#pm_code_DM").val(val)
    $("#pm_code_DY").val(val)
    return true
  
  $("#section_DC").change (e) ->
    val = $(e.currentTarget).val()
    $("#section_DM").val(val)
    $("#section_DY").val(val)
    return true
  
  $("#pm_code_VC").change (e) ->
    val = $(e.currentTarget).val()
    $("#pm_code_VM").val(val)
    $("#pm_code_VY").val(val)
    return true

  $("#section_VC").change (e) ->
    val = $(e.currentTarget).val()
    $("#section_VM").val(val)
    $("#section_VY").val(val)
    return true

  set_size_of field for field in $("[id^='search_']")
  $(window).resize ->
    set_size_of field for field in $("[id^='search_']")
