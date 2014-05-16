// #Copyright (c) 2014, IDEO 

describe( "NoamRefresher", function() {
  var divId = 'someDiv';
  var refreshRoute = '/some-route';
  var asyncRefreshRoute = '/asynch-route';
  var responseText = JSON.stringify({ 1: 'some response'});
  var asyncResponseText = JSON.stringify({ 1: 'another response'});
  var errorMessage = 'error message';

  var responses = {
    sync: [200, {"Content-Type": 'application/json' }, responseText],
    async: [200, {"Content-Type": 'application/json' }, asyncResponseText],
    error: [500, {"Content-Type": 'application/json' }, errorMessage]
  };


  var refresher;

  beforeEach( function() {
    $('body').append('<div id="' + divId + '"></div>');
    this.server = sinon.fakeServer.create();

    var params = {
      divToPopulate: divId,
      refreshRoute: refreshRoute,
      asyncRefreshRoute: asyncRefreshRoute,
      errorMessage: errorMessage,
      cb: function(results) {
          $("#" + this.divToPopulate).html(results['1'])
      },
      errorcb: function(error) {
            $("#" + this.divToPopulate).html(error.responseText);
      }
    };
    refresher = new NoamRefresher( params );
    this.clock = sinon.useFakeTimers();
  });

  afterEach( function() {
    $('#' + divId).remove();
    this.server.restore();
  });

  describe( 'Successful responses', function() {
    beforeEach( function() {
      refresher.go();
    });

    it( 'Populates div with AJAX response', function() {
      this.server.respondWith( 'GET', refreshRoute + "?time=0", responses.sync );

      this.server.respond();
      expect( $( '#' + divId )).toHaveHtml( 'some response' );
    });

    xit( 'Populates div with content from async refresh after initial refresh', function() {
      //TODO: how are asynch requests triggered?
      this.server.respondWith( 'GET', asyncRefreshRoute + "?time=1", responses.async );
      this.clock.tick( 1 );
      this.server.respond();

      expect( $( '#' + divId )).toHaveHtml( 'another response' );
    });
  });

  describe( 'Error responses', function() {
    beforeEach( function() {
      this.server.respondWith( 'GET', refreshRoute + "?time=0", responses.error );

      refresher.go();
      this.server.respond();
    });

    it( 'Populates div with error message', function() {
      expect( $( '#' + divId )).toHaveHtml( 'error message' );
    });

    it( 'Tries again after 1 second', function() {
      this.server.restore();
      this.server = sinon.fakeServer.create();
      this.server.respondWith( 'GET', refreshRoute + "?time=0", responses.sync );
      this.clock.tick( 1000 );
      this.server.respond();

      expect( $( '#' + divId )).toHaveHtml( 'some response' );
    });
  });
});
