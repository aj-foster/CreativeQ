<% unless @org.new_record? %>
	$('.js-create-org').prepend "<%= escape_javascript(render 'listing', org: @org) %>"
	$('#new_organization')[0].reset()
<% end %>