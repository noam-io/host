describe( "AssetRefresher", function() {
  var divId = 'someDiv';
  var refreshRoute = '/some-route';
  var responseText = 'some response';

  beforeEach( function() {
    $('body').append('<div id="' + divId + '"></div>');
    this.server = sinon.fakeServer.create();

    this.server.respondWith( 'GET', refreshRoute,
              [200, {"Content-Type": 'text/html' }, responseText]);

    var refresher = new AssetRefresher( divId, refreshRoute );
    refresher.go();
    this.server.respond();
  });

  afterEach( function() {
    $('#' + divId).remove();
    this.server.restore();
  });

  it( 'Populates div with AJAX response', function() {
    expect( $( '#' + divId )).toHaveHtml( responseText );
  });
    //jasmine.Clock.useMock();
    //jasmine.Clock.tick( 3000 );


    //expect( $.ajax.mostRecentCall.args[0]['url'] ).toEqual( '/boom' );
    //expect( $.ajax.mostRecentCall.args[0]['data'] ).toEqual( {x: 5} );

});
