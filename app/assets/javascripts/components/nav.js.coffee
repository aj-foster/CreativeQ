$(document).on 'change', '#nav-check', (evt) ->
  if $(this).prop 'checked'
    $(document).one 'click', (evt) ->
      $('#nav-check').prop 'checked', false