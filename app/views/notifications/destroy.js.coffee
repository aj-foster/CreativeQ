<% if @destroyed %>
  $('#notification_<%= @notification.id %>').fadeOut 500, ->
    $('#notification_<%= @notification.id %>').remove()
    if $('#js-notifications > .tile').length == 0
      $('#js-notifications').append '<div class="tile tile--placeholder">You do not have any notifications.</div>'
<% end %>