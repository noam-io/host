/*global noam, Backbone*/

noam.Models = noam.Models || {};

(function () {
    'use strict';

    noam.Models.AppModel = Backbone.Model.extend({
        url: function(){ return '/data/exhibits/' + this.id + '.json'; },
        initialize: function(){
        	return this;
        }
    });

})();
