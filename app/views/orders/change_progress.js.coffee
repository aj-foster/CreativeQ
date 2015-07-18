orderID = <%= @order.id %>
button = $("#progress-" + orderID)
button.val("✓")
button.on 'click', (evt) ->
	evt.preventDefault()
	false