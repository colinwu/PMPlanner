jQuery ->      
  groupNames = []
  groupIDs = {}
  codeNames = []
  codeIDs = {}
  url = document.documentURI
  if url.match(/\/parts_for_pms\/new$/) || url.match(/\/parts_for_pms\/\d+\/edit$/)
    $("#model_group_name").hide()
    $("#pm_code_name").hide()
    $.getJSON "/model_groups", (result) ->
      for mg in result
        gn = mg.name
        groupIDs[gn] = mg.id
        groupNames.push(gn)
      $("#model_group_name").autocomplete({ source: groupNames })
      $("#model_group_name").show()
      return true
    $.getJSON "/pm_codes", (result) ->
      for item in result
        cn = item.name
        codeNames.push(cn)
        codeIDs[cn] = item.id
      $("#pm_code_name").autocomplete({ source: codeNames })
      $("#pm_code_name").show()
      return true

