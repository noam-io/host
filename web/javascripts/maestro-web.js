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

  var isCheckedConfirm = function( form ) {
   return 0 < $(form).find("[name='confirm']:checked").length;
  };

  var processDeployAssetsSubmit = function() {
    if( !isCheckedConfirm( this )) {
      alert("You must check the 'confirm' box to perform this action.");
      return false;
    }
    return true;
  };

  $("#manual-event-form").submit( processManualEventSubmit );
  $("#deploy-assets-form").submit( processDeployAssetsSubmit );
  refreshStuff('/refresh');
});

