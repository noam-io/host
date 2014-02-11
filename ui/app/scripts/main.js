/*global noam, Backbone, $*/

window.noam = {
    Models: {},
    Collections: {},
    Views: {},
    Routers: {},
    Events: {},
    navView: {},
    appView: null,
    globals: {
        numberOfStories: 19, 
        maxNumberOfPages: 8
    },

    init: function () {
        'use strict';
        this.appView = new this.Views.AppView();
        window.exhibitRouter = new this.Routers.AppRouter();
    }
};

$(document).ready(function () {
    'use strict';
    noam.init();
    Backbone.history.start();
});
