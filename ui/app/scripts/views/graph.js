/*global noam, Backbone, JST*/

noam.Views = noam.Views || {};

(function () {
    'use strict';

    noam.Views.GraphView = Backbone.View.extend({
    	el: '#graph',
    	template: JST['app/scripts/templates/graphview.ejs'],
        events: {

        },
    	initialize: function(){
    		_.bindAll(this, 'render');
            this.render();
    	},
    	render: function(){
    		$(this.el).prepend(this.template());
    	},
    });

})();
