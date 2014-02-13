/*global ui, Backbone, JST*/

ui.Views = ui.Views || {};

(function () {
    'use strict';

    ui.Views.GraphView = Backbone.View.extend({
    	el: '.graph',
        div: null,
        d: {
            w: 1280,
            h: 800,
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

            // Draw background
            this.svg.append("svg:path")
                .attr("class", "arc")
                .attr("d", d3.svg.arc().outerRadius(this.d.ry - 120).innerRadius(0).startAngle(0).endAngle(2 * Math.PI))

            // Line generator
            this.line = d3.svg.line.radial()
                .interpolate("bundle")
                .tension(.85)
                .radius(function(d) { return d.y; })
                .angle(function(d) { return d.x / 180 * Math.PI; });
            
        },

        parseToD3: function() {
            var _this = this;

            d3.json(this.fakeData, function(data) {

                var d = _this.mapToNodes(data),
                    nodes = _this.cluster.nodes(_this.mapHierarchy(d)),
                    links = _this.getConnections(nodes),
                    splines = _this.bundle(links);

                console.log('nodes',nodes)
                console.log('links',links)
                console.log('splines',splines);
 

                var path = _this.svg.selectAll("path.link")
                    .data(links)
                    .enter().append("svg:path")
                    .attr("class", function(d) { return "link source-" + d.source.key + " target-" + d.target.key; })
                    .attr("d", function(d, i) { return _this.line(splines[i]); });


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
                      .text(function(d) { return d.name.split('root.')[1]; })
          });

        },


        // For sanity
        mapHierarchy: function(data) {
            var map = {};

            function find(name, data) {
                var node = map[name], i;
                if (!node) {
                  node = map[name] = data || {name: name, children: []};
                  if (name.length) {
                    node.parent = find(name.substring(0, i = name.lastIndexOf(".")));
                    node.parent.children.push(node);
                    node.key = name.substring(i + 1);
                  }
                }
                // console.log(node)
                return node;
            }

            _.each( data, function(d, i) {
                find(d.name, d);
            });

            // console.log('classes',classes)

            return map[""];
        },

        // For connectyness        
        getConnections: function(nodes) {
            var map = {},
              imports = [];

            // Compute a map from name to node.
            nodes.forEach(function(d) {
                map[d.name] = d;
            });

            // For each import, construct a link from the source to target node.
            nodes.forEach(function(d) {
                if (d.imports) d.imports.forEach(function(i) {
                  imports.push({source: map[d.name], target: map[i]});
                });
            });
            console.log(imports)
            return imports;
        },

        mapToNodes: function(data) {
            var map=[];
            _.each(data.players, function(val,iter) {
                var i={}, o={};
                i.name = 'root.' + val.spalla_id + '.in';
                i.size = Math.random() * 5000;
                i.imports = [];
                _.each(val.hears, function(dat,jter) {
                    i.imports.push('root.' + dat.split('sentFrom')[1] + '.out');
                });

                o.name = 'root.' + val.spalla_id + '.out';
                o.size = Math.random() * 5000;
                o.imports = [];
                _.each(val.plays, function(dat,jter) {
                    o.imports.push('root.' + dat.split('sentFrom')[1] + '.in');
                });

                map.push(i);
                map.push(o);
            })
            return map;
        },

    });

})();
