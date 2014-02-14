    /*global ui, Backbone*/

ui.Models = ui.Models || {};

(function () {
    'use strict';

    ui.Models.NoamModel = Backbone.Model.extend({

        url: '',

        initialize: function() {
        },

        defaults: {
        },

        validate: function(attrs, options) {
        },

        parse: function(response, options)  {
            return response;
        }
    });

})();
