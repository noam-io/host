$().ready(function() {
	var active = '.graph';

	$('#MainViewToggles a').each(function(){
		var isfor = $(this).attr('for');
		if($(this).hasClass('active')){
			$("."+isfor).show();
		} else {
			$("."+isfor).hide();
		}
	});


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
		$('.settings-container').addClass('active').show();
		$('.settings-container .dropdown-item').hide().fadeIn(300);

		$(this).find('.icon').addClass('active');
	})

	$('.network-button').on('click', function() {
		if($('.network-container').hasClass('active')) {
			closeDropdown()
			return;
		}
		closeDropdown();
		$('.network-container').addClass('active').show();
		$('.network-container .dropdown-item').hide().fadeIn(300);
		$(this).find('.icon').addClass('active');
	})

	function closeDropdown() {
		$('.dropdown-item-container.active .dropdown-item').fadeOut(300);
		$('.dropdown-item-container.active').removeClass('active');
		$('.nav-button').find('.active').removeClass('active');
	}

});