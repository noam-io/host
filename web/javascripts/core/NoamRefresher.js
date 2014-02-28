function NoamRefresher( params ) {
  this.params = params;
  this.time = 0;
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
  var self = this;
  
  var softRefresh = function() {
    populateFromUrl( params.asyncRefreshRoute );
  };

  var hardRefresh = function() {
    populateFromUrl( params.refreshRoute );
  };

  var populateFromUrl = function( route ) {
    $.ajax({
      url: route,
      data: {'time': self.time},
      dataType: 'json',
      success: function( results ){
        self.time = results['time'];
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

