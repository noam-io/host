// #Copyright (c) 2014, IDEO 

describe("Components click events", function() {

    beforeEach(function () {
        loadFixtures('indexBootstrap.html');
        initialize_menu_buttons();
    });

    it("adds the active class to settings container", function() {
        $('.settings-button').click();
        expect($('.settings-container')).toHaveClass('active');
    });

    it("adds the active class to network container", function() {
        $('.network-button').click();
        expect($('.network-container')).toHaveClass('active');
    });

    it("removes the active class from the settings container", function() {
        $('.settings-button').click();
        $(document).click();
        expect($('.settings-container')).not.toHaveClass('active');
    });

    it("removes the active class from the network container", function() {
        $('.network-button').click();
        $(document).click();
        expect($('.network-container')).not.toHaveClass('active');
    });

});