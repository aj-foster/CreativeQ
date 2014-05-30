$(document).on 'ready page:load', ->

	$('.role select').on 'change', ->
		if $(@).val() == 'Creative'
			$('.flavor').slideDown()
		else
			$('.flavor').slideUp()