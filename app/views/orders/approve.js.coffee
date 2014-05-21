orderID = <%= @order.id %>
button = $("#approve-" + orderID)

button.html("&#10003;").on 'click', (evt) ->
	evt.preventDefault()
	false