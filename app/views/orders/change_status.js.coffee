orderID = <%= @order.id %>
button = $("#status-" + orderID)
button.val("✓")
button.on 'click', (evt) ->
	evt.preventDefault()
	false