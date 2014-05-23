$(document).on 'ready page:load', ->

	# Allow users to see order descriptions by clicking on the orders
	$("tr.order").on 'click', (evt) ->

		# Don't display previews if the click was generated on a link
		unless evt.target.tagName == "A"

			# Use fancybox to open the preview immediately after the order
			$.fancybox.open($(@).next("tr.preview"), {maxWidth: 1200})


	# Use a datepicker to make entering due dates easier
	$(".datepicker").datepicker({ dateFormat: "mm/dd/yy", minDate: "+14d" })


	showNeeds = (target) ->

		targetClass = $(target).attr('data-flavor')

		$('.need-wrap').each ->

			if $(this).hasClass targetClass
				$(this).slideDown()
				$(this).find("input").each ->
					unless $(this).prop('data-disabled')
						$(this).attr('disabled', 'true')


			else
				$(this).slideUp()
				$(this).find("input").each ->
					if $(this).prop('disabled')
						$(this).attr('data-disabled', 'true')


	# Show the relevant form for each flavor of order
	showNeeds($(".flavor input[type='radio']"))
	$(".flavor input[type='radio']").on 'change', -> showNeeds(@)


	# Offer more information about the various "needs" in a modal
	$(".needs .fancybox").fancybox({maxWidth: 500})


	# Use the label of each order need to enable / disable the field
	$(".need-label").on 'click', (evt) ->

		evt.preventDefault()

		$(@).siblings("input").each ->
			this.disabled = !this.disabled