function NoamRefresher( params ) {
  this.params = params;
}

NoamRefresher.prototype.go = function( ) {
  var params = this.params;
  var div = $("#" + params.divToPopulate);

  var softRefresh = function() {
    populateFromUrl( params.asyncRefreshRoute );
  };

  var hardRefresh = function() {
    populateFromUrl( params.refreshRoute );
  };

  var populateFromUrl = function( route ) {
    $.ajax({
      url: route,
      success: function( html ){
        div.html( html );
        setTimeout( softRefresh, 1);
      },
      error: function() {
        div.html( params.errorMessage );
        setTimeout( hardRefresh, 1000);
      }
    });
  };

  hardRefresh();
};

