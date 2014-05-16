//Copyright (c) 2014, IDEO 

$().ready(initialize_menu_buttons());

function closeDropdown() {
    $('.dropdown-item-container.active .dropdown-item').fadeOut(300);
    $('.dropdown-item-container.active').removeClass('active');
    $('.nav-button').find('.active').removeClass('active');
}

function inside(event,selector) {
    return ($(event.target).closest(selector).length > 0)
}

function initialize_menu_buttons() {
    var active = '.graph';

    $('#MainViewToggles a').each(function(){
        var isfor = $(this).attr('for');
        if($(this).hasClass('active')){
            $("."+isfor).show();
        } else {
            $("."+isfor).hide();
        }
    });
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
    $('.settings-button').on('click', function(event) {
        if($('.settings-container').hasClass('active')) {
            closeDropdown();
            return;
        }
        closeDropdown();
        $('.settings-container').addClass('active').show();
        $('.settings-container .dropdown-item').hide().fadeIn(300);

        $(this).find('.icon').addClass('active');
        event.stopPropagation();
    });

    $('.network-button').on('click', function(event) {
        if($('.network-container').hasClass('active')) {
            closeDropdown();
            return;
        }
        closeDropdown();
        $('.network-container').addClass('active').show();
        $('.network-container .dropdown-item').hide().fadeIn(300);
        $(this).find('.icon').addClass('active');
        event.stopPropagation();
    });

    $(document).on('click', function(event) {
        if(!(inside(event,'.dropdown-item'))) {
            if($('.settings-container').hasClass('active') || $('.network-container').hasClass('active')) {
                closeDropdown();
                return;
            }
        }
    });
}
