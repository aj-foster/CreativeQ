orgID = <%= @org.id %>
button = $("#destroy-" + orgID)

button.html("&#10003;").on 'click', (evt) ->
	evt.preventDefault()
	false