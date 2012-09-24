function AssetRefresher( params ) {
  this.params = params;
}

AssetRefresher.prototype.go = function( ) {
  var params = this.params;
  var div = $("#" + params.divToPopulate);

  var refreshAgain = function() {
    populateFromUrl( params.asyncRefreshRoute );
  };

  var populateFromUrl = function( route ) {
    $.ajax({
      url: route,
      success: function( html ){
        div.html( html );
        setTimeout( refreshAgain, 1);
      },
      error: function() {
        div.html( params.errorMessage );
      }
    });
  };

  populateFromUrl( params.refreshRoute )
};

