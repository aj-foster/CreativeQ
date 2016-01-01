$(document).on 'ready page:load', ->

	# Allow users to see order descriptions by clicking on the orders
	# $(".js-order-preview").on 'click', (evt) ->
	#
	# 	# Grab the ID of the order we want to preview.
	# 	order_id = $(@).attr("data-order")
	#
	# 	# Use fancybox to open the preview immediately after the order
	# 	$.fancybox.open($(".preview[data-order='" + order_id + "']"), {maxWidth: 1200})
	#
	# 	# Prevent the default action
	# 	evt.preventDefault()

	$(".js-order-preview-link").fancybox({maxWidth: 1200, title: null})


	# Use a datepicker to make entering due dates easier
	$(".datepicker").datepicker({ dateFormat: "mm/dd/yy", minDate: "+14d" })


	showNeeds = (target) ->

		targetClass = $(target).attr('data-flavor')

		$('.js-needs').each ->

			if $(this).hasClass "js-needs--" + targetClass
				$(this).slideDown()
				$(this).find(".need-input").each ->
					unless $(this).attr('data-disabled') == "true"
						$(this).prop('disabled', false)


			else
				$(this).slideUp()
				$(this).find(".need-input").each ->
					$(this).attr('data-disabled', $(this).prop('disabled'))
					$(this).prop('disabled', true)


	# Show the relevant form for each flavor of order
	$(".js-flavor").on 'change', -> showNeeds(@)


	# Offer more information about the various "needs" in a modal
	$(".need .fancybox").fancybox({maxWidth: 500})


	# Use the label of each order need to enable / disable the field
	# $(".need-label").on 'click', (evt) ->
	#
	# 	evt.preventDefault()
	#
	# 	$(".video.need-wrap .need input").each ->
	# 		this.disabled = true
	#
	# 	$(@).siblings("input").each ->
	# 		this.disabled = !this.disabled

	$(".need-check").on 'change', ->
		new_value = !$(@).prop("checked")
		$(@).siblings(".need-input").each ->
			$(this).prop("disabled", new_value)


	# Activate tooltips
	$('[data-toggle="tooltip"]').tooltip()