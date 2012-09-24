describe( "AssetRefresher", function() {

  beforeEach( function() {
    $('body').append('<div id="refreshDiv">f</div>');

    this.server = sinon.fakeServer.create();
  });

  afterEach( function() {
    $('#refreshDiv').remove();
    this.server.restore();
  });

  it( 'Populates div with AJAX response', function() {
    var responseText = 'some response';

    this.server.respondWith( 'GET', '/boom',
              [200, {"Content-Type": 'text/html' }, responseText]);
    var refresher = new AssetRefresher("refreshDiv");
    refresher.go();
    this.server.respond();

    expect( $( "#refreshDiv" )).toHaveHtml( responseText );
  });
    //jasmine.Clock.useMock();
    //jasmine.Clock.tick( 3000 );


    //expect( $.ajax.mostRecentCall.args[0]['url'] ).toEqual( '/boom' );
    //expect( $.ajax.mostRecentCall.args[0]['data'] ).toEqual( {x: 5} );

});
