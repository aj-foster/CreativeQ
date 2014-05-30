assignmentID = <%= @assignment.id %>
button = $("#destroy-" + assignmentID)

button.html("&#10003;").on 'click', (evt) ->
	evt.preventDefault()
	false