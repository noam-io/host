
$(function() {
  $(".last-value").click( function() {
    $("#play-event-name").attr('value', $(this).data('event-name'));
    $("#play-event-value").attr('value', $(this).data('event-value'));
    $("#play-events").dialog('open');
  });
});
