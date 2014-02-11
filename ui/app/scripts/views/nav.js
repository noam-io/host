noam.Views = noam.Views || {};

(function () {
    'use strict';

    noam.Views.NavView = Backbone.View.extend({
    	el: 'body',
        navEl: '#navigation-fixed',
    	template: JST['app/scripts/templates/nav.ejs'],
        hidden: false,
        events: {

        },

    	initialize: function(){;
    		_.bindAll(this, 'render');
            this.render();
    	},

        render: function() {
            
        },
    });
})();