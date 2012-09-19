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
  refreshStuff('/refresh');
});

