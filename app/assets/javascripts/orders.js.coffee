$ ->

	$("tr.order").on 'click', (evt) -> $.fancybox.open($(@).next("tr.preview"), {maxWidth: 1200})