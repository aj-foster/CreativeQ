<% unless @assignment.new_record? %>
	$('.create option[value="<%= @assignment.organization.id %>"]').remove()
	$('.create').before "<%= escape_javascript(render 'assignments/listing', assignment: @assignment) %>"
<% end %>