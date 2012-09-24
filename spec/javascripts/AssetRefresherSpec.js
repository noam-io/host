describe( "AssetRefresher", function() {
  var divId = 'someDiv';
  var refreshRoute = '/some-route';
  var responseText = 'some response';
  var errorMessage = 'error message';

  var refresher;

  beforeEach( function() {
    $('body').append('<div id="' + divId + '"></div>');
    this.server = sinon.fakeServer.create();

    refresher = new AssetRefresher( divId, refreshRoute, errorMessage );
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

  it( 'Populates div with error message', function() {
    this.server.respondWith( 'GET', refreshRoute,
              [500, {"Content-Type": 'text/html' }, responseText]);

    refresher.go();
    this.server.respond();
    expect( $( '#' + divId )).toHaveHtml( errorMessage );
  });
    //jasmine.Clock.useMock();
    //jasmine.Clock.tick( 3000 );


    //expect( $.ajax.mostRecentCall.args[0]['url'] ).toEqual( '/boom' );
    //expect( $.ajax.mostRecentCall.args[0]['data'] ).toEqual( {x: 5} );

});
