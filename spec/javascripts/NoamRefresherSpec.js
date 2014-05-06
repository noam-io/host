xdescribe( "NoamRefresher", function() {
  var divId = 'someDiv';
  var refreshRoute = '/some-route';
  var asyncRefreshRoute = '/asynch-route';
  var responseText = 'some response';
  var asyncResponseText = 'another response';
  var errorMessage = 'error message';

  var responses = {
    sync: [200, {"Content-Type": 'text/html' }, responseText],
    async: [200, {"Content-Type": 'text/html' }, asyncResponseText],
    error: [500, {"Content-Type": 'text/html' }, '']
  };


  var refresher;

  beforeEach( function() {
    $('body').append('<div id="' + divId + '"></div>');
    this.server = sinon.fakeServer.create();

    var params = {
      divToPopulate: divId,
      refreshRoute: refreshRoute,
      asyncRefreshRoute: asyncRefreshRoute,
      errorMessage: errorMessage
    };
    refresher = new NoamRefresher( params );
    jasmine.Clock.useMock();
  });

  afterEach( function() {
    $('#' + divId).remove();
    this.server.restore();
  });

  describe( 'Succesfull responses', function() {
    beforeEach( function() {
      this.server.respondWith( 'GET', refreshRoute, responses.sync );

      refresher.go();
      this.server.respond();
    });

    it( 'Populates div with AJAX response', function() {
      expect( $( '#' + divId )).toHaveHtml( responseText );
    });

    it( 'Populates div with content from async refresh after initial refresh', function() {
      this.server.respondWith( 'GET', asyncRefreshRoute, responses.async );
      jasmine.Clock.tick( 1 );
      this.server.respond();

      expect( $( '#' + divId )).toHaveHtml( asyncResponseText );
    });
  });

  describe( 'Error responses', function() {
    beforeEach( function() {
      this.server.respondWith( 'GET', refreshRoute, responses.error );

      refresher.go();
      this.server.respond();
    });

    it( 'Populates div with error message', function() {
      expect( $( '#' + divId )).toHaveHtml( errorMessage );
    });

    it( 'Tries again after 1 second', function() {
      this.server.restore();
      this.server = sinon.fakeServer.create();
      this.server.respondWith( 'GET', refreshRoute, responses.sync );
      jasmine.Clock.tick( 1000 );
      this.server.respond();

      expect( $( '#' + divId )).toHaveHtml( responseText );
    });
  });
});
