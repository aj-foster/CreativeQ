orderID = <%= @order.id %>
button = $("#approve-" + orderID)

button.css("color", "#5EB160")
button.on 'click', (evt) ->
	evt.preventDefault()
	false