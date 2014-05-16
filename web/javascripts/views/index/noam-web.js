//Copyright (c) 2014, IDEO 

$(function() {
  var processManualEventSubmit = function() {
    $.post( this.action, $(this).serialize() );
    $("#play-events").dialog('close');
    return false;
  };

  $("#manual-event-form").submit( processManualEventSubmit );

  $("#play-events").dialog({
      autoOpen:false,
      modal: true,
      position: [100, 100],
      width: 550,
      height: 120,
      title: "Play Event"
       });

  var params = {
    divToPopulate: 'real-time-data',
    refreshRoute: '/refresh',
    asyncRefreshRoute: '/arefresh',
    errorMessage: 'Contacting Maestro &hellip;'
  };
  var refresher = new NoamRefresher( params );
  refresher.go();
  

});

