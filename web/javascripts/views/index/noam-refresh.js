//Copyright (c) 2014, IDEO 

$(function() {
  $(".last-value").click( function() {
    $("#play-event-name").attr('value', $(this).data('event-name'));
    $("#play-event-value").attr('value', $(this).data('event-value'));
    $("#play-events").dialog('open');
    $("#play-event-value").focus();
  });

  $(".active").effect( "highlight",{color:"#FF530D"} );

  $("abbr.timeago").timeago();
});

