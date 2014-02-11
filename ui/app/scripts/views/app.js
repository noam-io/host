/*global noam, Backbone, JST*/

noam.Views = noam.Views || {};

(function () {
    'use strict';

    noam.Views.AppView = Backbone.View.extend({
    	el: 'body',
    	template: JST['app/scripts/templates/appview.ejs'],
        events: {

        },
    	initialize: function(){
    		_.bindAll(this, 'render');
            this.render();
            this.graph = new noam.Views.GraphView();
    	},
    	render: function(){
    		$(this.el).prepend(this.template());
    	},
    });

})();
