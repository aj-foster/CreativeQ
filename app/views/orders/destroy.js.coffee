orderID = <%= @order.id %>
button = $("#destroy-" + orderID)

button.html("&#10003;").on 'click', (evt) ->
	evt.preventDefault()
	false