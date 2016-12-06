$(document).on 'turbolinks:load', ->

	$('#user_role').on 'change', ->
		if $(@).val() == 'Creative'
			$('.js-user-flavor').slideDown()
		else
			$('.js-user-flavor').slideUp()