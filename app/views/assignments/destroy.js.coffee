<% if @destroyed %>
  $('#assignment_<%= @assignment.id %>').fadeOut 500, ->
    $('#assignment_<%= @assignment.id %>').remove()
<% end %>