/*global ui, Backbone, JST*/

ui.Views = ui.Views || {};

(function () {
    'use strict';

    ui.Views.GraphView = Backbone.View.extend({
    	el: '.graph',
        div: null,
        d: {
            w: 1280,
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

            // Draw background
            this.svg.append("svg:path")
                .attr("class", "arc")
                .attr("d", d3.svg.arc()
                    .outerRadius(this.d.ry-120)
                    .innerRadius(0)
                    .startAngle(0)
                    .endAngle(2 * Math.PI))

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

                console.log('mappedData',d);
                console.log('nodes',nodes);
                console.log('links',links);
                console.log('splines',splines);
 
                 _this.drawCategory(nodes);

                var path = _this.svg.selectAll("path.link")
                    .data(links)
                    .enter().append("svg:path")
                    .attr("class", function(d) { return "link name-" + d.source.name.split('.')[1] + " source-" + d.source.name.split('.')[1] + " target-" + d.target.name.split('.')[1]; })
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
                      .text(function(d) { return d.name.split('participant.')[1]; })
                      .on("mouseover", _this.mouseon)
                      .on("mouseout", _this.mouseoff);

                
          });
        },


        drawCategory: function(nodes) {
            var _this = this;

            // console.log("filtered nodes",nodes.filter(function(d) { return d.name.split('.').length == 2 ? d : null  && d.children; }));
            var groups = this.svg.selectAll("g.group")
              .data(nodes.filter(function(d) {
                 console.log("categoryNodeFilter",d);
                 return d.x ? d : null && d.children;
             }))
            .enter().append("group")
              .attr("class", "group");


            var groupArc = d3.svg.arc()
                .innerRadius(this.d.ry-120)
                .outerRadius(this.d.ry-160)
                .startAngle(function(d){ var r=_this.getAngles(d.__data__); return r.min; })
                .endAngle(function(d){ var r=_this.getAngles(d.__data__); return r.max; });

            console.log("groups",groups);
            console.log("groupArc",groupArc);

          this.svg.selectAll("g.arc")
            .data(groups[0])
            .enter().append("svg:path")
            .attr("d", groupArc)
            .attr("class", "groupArc")
            .style("fill", "#1f77b4")
            .style("fill-opacity", 0.5)
            .text(function(d){
                
            })

        },

        getAngles: function(data) {
            var min,max = 0;
            // console.log('getAnglesInput',data.x)
            if(!data.children) {
                console.log("Noe kids")
                return { min: 0, max:0 };
            }
            min = max = data.children[0].x;
           data.children.forEach(function(d){
               if(d.x < min) min = d.x;
               if(d.x > max) max = d.x;
           });
            var pi = Math.PI;
            console.log('minmax return',{ min: min-2 * (pi/180), max: max+2 * (pi/180)});
            return { min: (min-2) * (pi/180), max: (max+2) * (pi/180)};
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
                i.name = 'participant.' + val.spalla_id + '.hears';
                i.size = Math.random() * 5000;
                i.imports = [];
                _.each(val.hears, function(dat,jter) {
                    i.imports.push('participant.' + dat.split('sentFrom')[1] + '.plays');
                });

                o.name = 'participant.' + val.spalla_id + '.plays';
                o.size = Math.random() * 5000;
                o.imports = [];
                // Commented this out, causes Lemmas that talk to eachother
                // _.each(val.plays, function(dat,jter) {
                //     o.imports.push('participant.' + dat.split('sentFrom')[1] + '.in');
                // });

                map.push(i);
                map.push(o);
            })
            return map;
        },

        mouseon: function(d) {
            var _this = window.ui.graphView;
            //console.log('mouseon',d.name)
            _this.svg.selectAll("path.link.target-" + d.name.split('.')[1])
              .classed("target", true)
              .each(_this.updateNodes("source", true));

            _this.svg.selectAll("path.link.source-" + d.name.split('.')[1])
              .classed("source", true)
              .each(_this.updateNodes("target", true));
            },
 
        mouseoff:function(d) {
            var _this = window.ui.graphView;
            _this.svg.selectAll("path.link.source-" + d.name.split('.')[1])
              .classed("source", false)
              .each(_this.updateNodes("target", false));

            _this.svg.selectAll("path.link.target-" + d.name.split('.')[1])
              .classed("target", false)
              .each(_this.updateNodes("source", false));
        },

        updateNodes: function(name, value) {
            var _this = window.ui.graphView;
          return function(d) {
            //console.log('updateNotdes',this)
            if (value) this.parentNode.appendChild(this);
            _this.svg.select("#node-" + d[name].key).classed(name, value);
          };
        }

    });

})();
