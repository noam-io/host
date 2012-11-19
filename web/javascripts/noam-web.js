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
  $("#deploy-assets").dialog({
      autoOpen:false,
      modal: true,
      position: [100, 100],
      width: 800,
      height: 550,
      title: "Deploy Assets"
       });

  var params = {
    divToPopulate: 'real-time-data',
    refreshRoute: '/refresh',
    asyncRefreshRoute: '/arefresh',
    errorMessage: 'Contacting Maestro &hellip;'
  };
  var refresher = new AssetRefresher( params );
  refresher.go();
  
});

