$().ready(function() {
	var active = '.graph';

	$('.grid-view').hide();


	// Graph buttons
	$('.graph-button').on('click', function() {
		$('.grid-view').hide();
		$('.graph-view').show();
		$('.graph-grid-menu').find('.active').removeClass('active');
		$(this).parent().addClass('active');
	})
	$('.grid-button').on('click', function() {
		$('.grid-view').show();
		$('.graph-view').hide();
		$('.graph-grid-menu').find('.active').removeClass('active');
		$(this).parent().addClass('active');
	})

	// Nav buttons
	$('.settings-button').on('click', function() {
		if($('.settings-container').hasClass('active')) {
			closeDropdown()
			return;
		}
		closeDropdown();
		$('.settings-container').addClass('active').slideDown();
		$(this).find('.icon').addClass('active');
	})

	$('.network-button').on('click', function() {
		if($('.network-container').hasClass('active')) {
			closeDropdown()
			return;
		}
		closeDropdown();
		$('.network-container').addClass('active').slideDown();
		$(this).find('.icon').addClass('active');
	})

	function closeDropdown() {
		$('.dropdown-item-container.active').removeClass('active').slideUp();
		$('.nav-button').find('.active').removeClass('active');
	}

});