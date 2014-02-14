/*global ui, Backbone*/

ui.Collections = ui.Collections || {};

(function () {
    'use strict';

    ui.Collections.NoamCollection = Backbone.Collection.extend({

        model: ui.Models.NoamModel,
        url: '//localhost:8081/refresh'


    });

})();
