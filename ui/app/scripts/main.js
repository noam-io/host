/*global ui, $*/


window.ui = {
    Models: {},
    Collections: {},
    Views: {},
    Routers: {},
    init: function () {
        'use strict';
        console.log('Hello from Backbone!');
        this.collection = new ui.Collections.NoamCollection();
        this.graphView = new ui.Views.GraphView({collection:this.collection});
    }
};

$(document).ready(function () {
    'use strict';
    ui.init();
});
