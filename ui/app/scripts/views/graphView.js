/*global ui, Backbone, JST*/

ui.Views = ui.Views || {};

(function () {
    'use strict';

    ui.Views.ExhibitView = Backbone.View.extend({
    	el: '#graph',
        //template: JST['app/scripts/templates/exhibit.ejs'],
        events: {
            
        },

        initialize: function(){
        	_.bindAll(this, 'render');
        	this.render();
        },

        render: function(){
            
            
            

        },	
    });

})();
