$(document).on 'ready page:load', ->
  $('.flash').each (index) ->
    element = $(this)

    setTimeout ->
      element.addClass('is-visible')
    , index * 6000

    setTimeout ->
      element.removeClass('is-visible')
    , index * 6000 + 5500