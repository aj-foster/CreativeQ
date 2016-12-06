$(document).on 'turbolinks:load', ->
  $('.flash').each (index) ->
    element = $(this)

    setTimeout ->
      element.addClass('is-visible')
    , index * 5000

    setTimeout ->
      element.removeClass('is-visible')
    , index * 5000 + 5500