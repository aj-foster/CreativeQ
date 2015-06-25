<% if @saved %>
	$('#edit_assignment_<%= @assignment.id %> select').after "<span class='temp temp--success'></span>"
<% else %>
  $('#edit_assignment_<%= @assignment.id %> select').after "<span class='temp temp--failure'></span>"
<% end %>