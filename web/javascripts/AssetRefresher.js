function AssetRefresher( divToPopulate ) {
  this.divToPopulate = divToPopulate;
}

AssetRefresher.prototype.go = function( ) {
  var that = this;

  $.ajax({
    url: '/boom',
    success: function( html ){
      var div = $("#" + that.divToPopulate);
      div.html( html );
    }
  });
};

