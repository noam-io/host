function AssetRefresher( params ) {
  this.params = params;
}

AssetRefresher.prototype.go = function( ) {
  var params = this.params;
  var div = $("#" + params.divToPopulate);

  $.ajax({
    url: params.refreshRoute,
    success: function( html ){
      div.html( html );
    },
    error: function() {
      div.html( params.errorMessage );
    }
  });
};

