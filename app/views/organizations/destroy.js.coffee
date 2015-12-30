<% if @destroyed %>
  $('#organization_<%= @org.id %>').fadeOut 500, ->
    $('#organization_<%= @org.id %>').remove()
<% end %>