function NoamRefresher( params ) {
  this.params = params;

  if(!this.params.cb){
    this.params.cb = function(results){
      console.log(results);
    }
  }

  if(!this.params.errorcb){
    this.params.errorcb = function(error){
      console.log("ERROR: ");
      console.log(error);
    }
  }
}

NoamRefresher.prototype.go = function( ) {
  var params = this.params;
  
  var softRefresh = function() {
    populateFromUrl( params.asyncRefreshRoute );
  };

  var hardRefresh = function() {
    populateFromUrl( params.refreshRoute );
  };

  var populateFromUrl = function( route ) {
    $.ajax({
      url: route,
      dataType: 'json',
      success: function( results ){
        setTimeout( softRefresh, 1);
        params.cb( results );
      },
      error: function(error) {
        params.errorcb( error );
        setTimeout( hardRefresh, 1000);
      }
    });
  };

  hardRefresh();
};

