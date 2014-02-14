$().ready(function() {
	var active = '.graph';

	$('.grid-view').hide();

	$('.graph-button').on('click', function() {
		$('.grid-view').hide();
		$('.graph-view').show();
	})
	$('.grid-button').on('click', function() {
		$('.grid-view').show();
		$('.graph-view').hide();
	})

});