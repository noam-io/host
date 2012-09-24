describe( "AssetRefresher", function() {

  beforeEach( function() {
    jasmine.Ajax.useMock();

    $('body').append('<div id="refreshDiv">f</div>');
  });

  afterEach( function() {
    $('#refreshDiv').remove();
  });

  it( 'Populates div with AJAX response', function() {
    var responseText = 'some response';

    var refresher = new AssetRefresher("refreshDiv");

    refresher.go();

    var request = mostRecentAjaxRequest();
    var response = {
      status: 200,
      responseHeaders: {"Content-type": 'text/html'},
      responseText: responseText
    }
    request.response( response );

    expect( $( "#refreshDiv" )).toHaveHtml( responseText );

  });

    //jasmine.Clock.useMock();
    //jasmine.Clock.tick( 3000 );


    //expect( $.ajax.mostRecentCall.args[0]['url'] ).toEqual( '/boom' );
    //expect( $.ajax.mostRecentCall.args[0]['data'] ).toEqual( {x: 5} );

});
