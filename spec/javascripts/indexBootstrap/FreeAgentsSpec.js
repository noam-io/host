describe("order alphabetically lemmas", function() {

    beforeEach(function () {
        loadFixtures('indexBootstrap.html');
        this.server = sinon.fakeServer.create();
        this.agentManager = new GuestList({
            'url': "/guests",
            'async_url': "/aguests",
            'freeElementQuery': "#freeAgentList ul",
            'ownedElementQuery': "#ownedAgentList ul"
        });
    });

    it("calls /guests with guests-free-order=asc and changes the class to arrow-up", function() {
        this.server.respondWith( 'GET', '/guests?time=0&guests-free-order=asc', [200, {"Content-Type": 'application/json' },
            JSON.stringify({ 1: 2})]);
        this.agentManager.free_agents_asc_refresh();

        this.server.respond();

        expect($('#free-guests-order-link i')).toHaveClass('glyphicon-arrow-up');
    });

    it("calls /guests with guests-free-order=desc and changes the class to arrow-down", function() {
        this.server.respondWith( 'GET', '/guests?time=0&guests-free-order=desc', [200, {"Content-Type": 'application/json' }, JSON.stringify([{ id: 1 }])]);
        this.agentManager.free_agents_desc_refresh();

        this.server.respond();

        expect($('#free-guests-order-link i')).toHaveClass('glyphicon-arrow-down');
    });

    it("calls /guests with owned-free-order=asc and changes the class to arrow-up", function() {
        this.server.respondWith( 'GET', '/guests?time=0&guests-owned-order=asc', [200, {"Content-Type": 'application/json' },
            JSON.stringify({ 1: 2})]);
        this.agentManager.owned_agents_asc_refresh();

        this.server.respond();

        expect($('#owned-guests-order-link i')).toHaveClass('glyphicon-arrow-up');
    });

    it("calls /guests with order=desc and changes the class to arrow-down", function() {
        this.server.respondWith( 'GET', '/guests?time=0&guests-owned-order=desc', [200, {"Content-Type": 'application/json' }, JSON.stringify([{ id: 1 }])]);
        this.agentManager.owned_agents_desc_refresh();

        this.server.respond();

        expect($('#owned-guests-order-link i')).toHaveClass('glyphicon-arrow-down');
    });

});