
$(function() {
  $(".last-value").click( function() {
    $("#play-event-name").attr('value', $(this).data('event-name'));
    $("#play-event-value").attr('value', $(this).data('event-value'));
    $("#play-events").dialog('open');
    $("#play-event-value").focus();
  });


  $(".active").effect( "highlight" );

  $(".deploy").click( function() {
    var spalla_id = $(this).data('spalla-id');
    $.ajax({
      url: "/show-assets",
      success: function(e) {
        $("#deploy-assets").html(e);
        $("#spalla-" + spalla_id).attr("checked", "true");
        $("#deploy-assets-form").submit( processDeployAssetsSubmit );
        $("#deploy-assets").dialog('open');
      },
    });
  });


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

});
