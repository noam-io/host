describe( "AssetRefresher", function() {
  var divId = 'someDiv';
  var refreshRoute = '/some-route';
  var asyncRefreshRoute = '/asynch-route';
  var responseText = 'some response';
  var asyncResponseText = 'another response';
  var errorMessage = 'error message';

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
    refresher = new AssetRefresher( params );
    jasmine.Clock.useMock();
  });

  afterEach( function() {
    $('#' + divId).remove();
    this.server.restore();
  });

  it( 'Populates div with AJAX response', function() {
    this.server.respondWith( 'GET', refreshRoute,
              [200, {"Content-Type": 'text/html' }, responseText]);

    refresher.go();
    this.server.respond();
    expect( $( '#' + divId )).toHaveHtml( responseText );
  });

  it( 'loads content from async refresh after initial refresh', function() {
    this.server.respondWith( 'GET', refreshRoute,
              [200, {"Content-Type": 'text/html' }, responseText]);
    this.server.respondWith( 'GET', asyncRefreshRoute,
              [200, {"Content-Type": 'text/html' }, asyncResponseText]);
    refresher.go();
    this.server.respond();
    jasmine.Clock.tick( 1 );
    this.server.respond();
    expect( $( '#' + divId )).toHaveHtml( asyncResponseText );
  });

  it( 'Populates div with error message', function() {
    this.server.respondWith( 'GET', refreshRoute,
              [500, {"Content-Type": 'text/html' }, responseText]);

    refresher.go();
    this.server.respond();
    expect( $( '#' + divId )).toHaveHtml( errorMessage );
  });
    //jasmine.Clock.tick( 3000 );


    //expect( $.ajax.mostRecentCall.args[0]['url'] ).toEqual( '/boom' );
    //expect( $.ajax.mostRecentCall.args[0]['data'] ).toEqual( {x: 5} );

});
