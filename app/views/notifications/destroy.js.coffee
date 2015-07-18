<% if @destroyed %>
  $('#notification_<%= @notification.id %>').fadeOut 500, ->
    $('#notification_<%= @notification.id %>').remove()
<% end %>