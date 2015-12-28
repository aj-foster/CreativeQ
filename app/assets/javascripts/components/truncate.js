$(document).ready(function () {
  $(document).on('click', '.js-truncate-link', function (evt) {
    evt.preventDefault();
    $(this).parent().css("height", "");
    $(this).parent().removeClass('js-truncate--hidden');
    $(this).remove();
  });
});

$(document).on('ready page:load', function () {
  $(".js-truncate").each(function () {
    if ($(this).height() > $(this).attr('data-truncate-height')) {
      $(this).css("height", $(this).attr('data-truncate-height') + 'px');
      $(this).addClass('js-truncate--hidden');
      $(this).append("<a class='js-truncate-link' href='#'>See more</a>");
    }
  });
});