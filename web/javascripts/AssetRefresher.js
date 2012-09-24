function AssetRefresher( divToPopulate, refreshRoute ) {
  this.divToPopulate = divToPopulate;
  this.refreshRoute = refreshRoute;
}

AssetRefresher.prototype.go = function( ) {
  var that = this;

  $.ajax({
    url: that.refreshRoute,
    success: function( html ){
      var div = $("#" + that.divToPopulate);
      div.html( html );
    },
    error: function() {
    }
  });
};

