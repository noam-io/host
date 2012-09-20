function refreshStuff(route) {
  $.ajax({
    url: route,
    success: function(e) {
      $("#real-time-data").html(e);
      setTimeout("refreshStuff('/arefresh')", 1);
    },
    timeout: 90000,
    error: function(e) {
      $("#real-time-data").html("Maestro is down");
      setTimeout("refreshStuff('/refresh')", 1000);
    }
  });
}

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
  refreshStuff('/refresh');
});

