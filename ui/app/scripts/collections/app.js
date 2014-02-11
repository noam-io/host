/*global noam, Backbone*/

noam.Collections = noam.Collections || {};

(function () {
    'use strict';

    noam.Collections.Participants = Backbone.Collection.extend({

        model: noam.Models.AppModel,
        // comparator: 'categoryId',
        // url: function(){ return '/data/exhibits.json'; },
        initialize: function(){
        	return this;
        },

        getAtIndex: function(index) {
        	if(index > this.length) index = 0;
        	if(index < 0) index = this.length-1;
        	return this.at(index);
        }


    });

})();
