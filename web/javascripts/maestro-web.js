function refreshStuff(route) {
  $.ajax({
    url: route,
    success: function(e) {
      $("#real-time-data").html(e);
      setTimeout("refreshStuff('/arefresh')", 1);
    },
    error: function(e) {
      $("#real-time-data").html("Maestro is down");
      setTimeout("refreshStuff('/refresh')", 1000);
    }
  });
}

$(function() {
  var processManualEventSubmit = function() {
    $.post( this.action, $(this).serialize() );
    return false;
  };

  $("#manual-event-form").submit( processManualEventSubmit );
  refreshStuff('/refresh');
});

