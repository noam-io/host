/*global ui, $*/


window.ui = {
    Models: {},
    Collections: {},
    Views: {},
    Routers: {},
    init: function () {
        'use strict';
        console.log('Hello from Backbone!');
        this.graphView = new ui.Views.GraphView();
    }
};

$(document).ready(function () {
    'use strict';
    ui.init();
});
