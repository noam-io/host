/*global ui, Backbone, JST*/

ui.Views = ui.Views || {};

(function () {
    'use strict';

    ui.Views.GraphView = Backbone.View.extend({
    	el: '.graph',
        div: null,
        d: {
            w: 960,
            h: 960,
            rx: 960/2,
            ry: 960/2
        },
        d3: null,
        bundle: null,
        cluster: null,
        line: null,
        svg: null,
        fakeData: 'data/dummy.json',



        events: {
            // Click on an participant to open a new view
            // hover on an edge
        },

        initialize: function(){
        	_.bindAll(this, 'render');

            this.setupGraph();
            this.parseToD3();
        	this.render();
        },

        render: function(){
            
            
            

        },	

        setupGraph: function() {
            var _this = this;

            // Setup the data clustering
            this.cluster = d3.layout.cluster()
                .size([360, this.d.ry-120]) // Degrees, radius
                .sort( function(a,b){
                    return d3.ascending(a.key, b.key);
                });

            // Setup the layout bundle
            this.bundle = d3.layout.bundle();

            // Setup radial line generator
            this.line = d3.svg.line.radial()
                .interpolate('bundle')
                .tension(.85)
                .radius( function(d) {
                    return d.y;
                })
                .angle( function(d) {
                    return d.x/180 * Math.PI;
                });

            // Generates the containing div
            this.div = d3.select(this.el)
                .insert("div", "h2")
                .style("width", this.d.w + "px")
                .style("height", this.d.h + "px")
                .style("position", "absolute")
                .style("-webkit-backface-visibility", "hidden");
            // Binds svg to the containing div
            this.svg = this.div.append('svg:svg')
                .attr('width',this.d.w)
                .attr('height',this.d.h)
                .append('svg:g')
                .attr('transform','translate(' + this.d.rx + ',' + this.d.ry + ')' );
            
        },

        parseToD3: function() {
            var _this = this;

            d3.json(this.fakeData, function(data) {

                var d = _this.pruneDataForViz(data),
                    nodes = _this.cluster.nodes(d),
                    links = _this.getConnections(nodes),
                    splines = _this.bundle(links);

                console.log(links);
 
                _this.svg.selectAll('g.node')
                    .data(nodes)
                    .enter().append("svg:g")
                    .attr('class','node')
                    .attr('id', function(d){ return "node-" + d.id});

                _this.svg.selectAll("g.node")
                    .data(nodes.filter(function(n) { return !n.children; }))
                    .enter().append("svg:g")
                    .attr("class", "node")
                    .attr("id", function(d) { return "node-" + d.key; })
                    .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; })
                    .append("svg:text")
                    .attr("dx", function(d) { return d.x < 180 ? 8 : -8; })
                    .attr("dy", ".31em")
                    .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
                    .attr("transform", function(d) { return d.x < 180 ? null : "rotate(180)"; })
                    .text(function(d) { return d.id; })
                }); 
        },


        // For sanity
        pruneDataForViz: function(data) {
            var d = {};
            _.each(data.players, function(v,i) {
                // Define structure
                d[v.spalla_id] = {};
                d[v.spalla_id].id = v.spalla_id;
                d[v.spalla_id].in = [];
                d[v.spalla_id].out = [];
                d[v.spalla_id].parent = null;
                d[v.spalla_id].children = null;
                d[v.spalla_id].depth = 0;
                // Populate data coming in
                _.each(v.hears, function(val,iter) {
                    d[v.spalla_id].in.push(val);
                });
                // Populate data coming out
                _.each(v.plays, function(val,iter) {
                    d[v.spalla_id].out.push(val);
                });
            });
            return d;
        },


        // What is a lemma hearing?
        getAllTopics: function(data) {
            var map=[];
            _.map(data.players, function(d) {
                _.each(d.hears, function(val,iter) {
                    map.push(val);
                });
                _.each(d.plays, function(val,iter) {
                    map.push(val);
                });
            })
            return _.uniq(map);
        },

        // What is a lemma saying?
        getParticipants: function(data) {
            var map = _.map(data.participants, function(d) {
                return d.id;
            });
            console.log(map);
            return map;
        },

        // For connectyness        
        getConnections: function(data) {
            var map = {}, d = [];
            console.log(data);
            _.each(data, function(e,r) {
                _.each(e, function(list,i) {
                    _.each(list.out, function(event, j) {
                        var targetId = event.split('sentFrom')[1];
                        var target = _.findWhere(data, {id:targetId})
                        d.push({ source: list, target: target});
                    })
                })
            });
            console.log(d)
            return d;
        },

    });

})();
