$(document).on 'ready page:load', ->

	$('#user_role').on 'change', ->
		if $(@).val() == 'Creative'
			$('.js-user-flavor').slideDown()
		else
			$('.js-user-flavor').slideUp()