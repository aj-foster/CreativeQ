<% unless @org.new_record? %>
	$('.organizations.index .create').before "<%= escape_javascript(render 'listing', org: @org) %>"
	$('.create input[type="text"]').val("")
<% end %>