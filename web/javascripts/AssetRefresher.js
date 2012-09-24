function AssetRefresher( divToPopulate, refreshRoute, errorMessage ) {
  this.divToPopulate = divToPopulate;
  this.refreshRoute = refreshRoute;
  this.errorMessage = errorMessage;
}

AssetRefresher.prototype.go = function( ) {
  var div = $("#" + this.divToPopulate);
  var that = this;

  $.ajax({
    url: that.refreshRoute,
    success: function( html ){
      div.html( html );
    },
    error: function() {
      div.html( that.errorMessage );
    }
  });
};

