$(document).on 'click touchend', (evt) ->
  console.log evt
  if evt.target.id != "nav-check" && $('#nav-check').prop 'checked'
    $('#nav-check').prop 'checked', false

$(document).on 'click touchend', '.nav, .nav-toggle', (evt) ->
  evt.stopPropagation()