<% if @saved %>
	$('#edit_order_<%= @order.id %> select').after "<span class='temp temp--success'></span>"
<% else %>
  $('#edit_order_<%= @order.id %> select').after "<span class='temp temp--failure'></span>"
<% end %>