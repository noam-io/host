/*global noam, Backbone*/

noam.Routers = noam.Routers || {};

(function () {
    'use strict';

    introView: null,

    noam.Routers.AppRouter = Backbone.Router.extend({
    	routes: {
    		"" : "render"
    	},

        initialize: function() {
            
        },

    	render: function(){
    		this.appView = new noam.Views.AppView();
    	},
    });
})();
