(function () {
    'use strict';

    window.graphView = {
    	el: '.graph',
        div: null,
        d: {
            w: $(window).height()*.88,
            h: $(window).height()*.88,
            rx: $(window).height()*.44,
            ry: $(window).height()*.44
        },
        d3: null,
        lastEvent: [],
        bundle: null,
        cluster: null,
        line: null,
        svg: null,
        timer: null,
        colors:[ '#210050','#46007a','#7f00de','#018b88','#01b8b1','#01ead6','#1667af','#01aeff','#6ed1ff','#73115b','#af007c','#d03593' ],
        fakeData: 'javascripts/data/dummy.json',

        init: function(data){
            var _this = this;

            // console.log('started graphview')

            _this.setupGraph();
            _this.parseToD3(data);
            _this.render();

        },

        render: function(){
            
            

        },	

        update: function(eventData) {
            var _this = this;
            var d = this.parseEventData(eventData);
            // console.log(d);

            _.each(d,function(val,key){
                var select = _this.svg.selectAll("path.link.target-" + val)
                  .each(_this.updateNodes("source", true))
                  .transition()
                    .style("opacity", 1)
                    .style('stroke-width','5px')
                    .duration(400);

                select.transition()
                    .style("opacity", .4)
                    .style('stroke-width','2px')
                    .duration(400)
                    .delay(400);
              })
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
            this.div = d3.select('.graph')
                .insert("div", "h2")
                .style("width", "100%")//this.d.w + "px")
                .style("height", this.d.h + "px")
                .style("position", "absolute")
                .style("left","0px")
                .style("-webkit-backface-visibility", "hidden");

            // Binds svg to the containing div
            this.svg = this.div.append('svg:svg')
                .style('margin','0 auto')
                .attr('width',this.d.w)
                .attr('height',this.d.h)
                .append('svg:g')
                .attr('transform','translate(' + this.d.rx + ',' + this.d.ry + ')' );

            // Line generator
            this.line = d3.svg.line.radial()
                .interpolate("bundle")
                .tension(.55)
                .radius(function(d) { return d.y; })
                .angle(function(d) { return d.x / 180 * Math.PI; });
            
        },

        parseToD3: function(collectionData) {
            var _this = this;
            // d3.json(collectionData, function(data) {

                // Main elements
            var d = _this.mapToNodes(collectionData),
                nodes = _this.cluster.nodes(_this.mapHierarchy(d)),
                links = _this.getConnections(nodes),
                splines = _this.bundle(links);

            // console.log('mappedData',d);
            // console.log('nodes',nodes);
            // console.log('links',links);
            // console.log('splines',splines);

            _this.drawCategory(nodes);

            // Draw arrow markers
            var markers = _this.svg.append("svg:defs").selectAll("marker")
                .data(links)
                .enter().append("svg:marker")
                .attr("id", function(d) { return d.target.name.split('.')[2] })
                .attr("class","marker")
                .attr("viewBox", "0 -5 10 10")
                .attr("refX", 0)
                .attr("markerWidth", 4)
                .attr("markerHeight", 4)
                .attr("orient", "auto")
                .append("svg:path")
                .attr("d", "M0,0L10,0L10,4")
                // .attr("transform", function(d) { return "rotate(" + (d.source.x) + ")"; })


             // Establish paths from links
            var path = _this.svg.selectAll("path.link")
                .data(links)
                .enter().append("svg:path")
                .attr("class", function(d) { return "link name-" + d.source.name.split('.')[2] + " source-" + d.source.name.split('.')[2] + " target-" + d.target.name.split('.')[2]; })
                .attr("marker-mid", function(d) {
                  //  if(d.)
                    return "url(#" + d.source.name.split('.')[2] + ")"; 
                })
                .attr("d", function(d, i) { return _this.line(splines[i]) ; });



                // Establish nodes for text display
            _this.svg.selectAll("g.node")
                  .data(nodes.filter(function(d) { return !d.children; }))
                .enter().append("svg:g")
                  .attr("class", "node")
                  .attr("id", function(d) { return "node-" + d.key; })
                  .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; })
                .append("svg:text")
                  .attr("dx", function(d) { return d.x < 180 ? 8 : -8; })
                  .attr("dy", ".31em")
                  .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
                  .attr("transform", function(d) { return d.x < 180 ? null : "rotate(180)"; })
                  .text(function(d) { return d.name.split('.')[2]; })
                  .on("mouseover", _this.mouseon)
                  .on("mouseout", _this.mouseoff);                
          // });
        },


        drawCategory: function(nodes) {
            var _this = this;
            
            // Arc Generator
            var groupArc = d3.svg.arc()
                .innerRadius(this.d.ry-120)
                .outerRadius(this.d.ry-160)
                .startAngle(function(d){ var r=_this.getAngles(d); return r.min; })
                .endAngle(function(d){ var r=_this.getAngles(d); return r.max; });

        
            this.svg.selectAll("g.arc")
                .data(nodes.filter(function(d){
                    return d.name !== 'participant' && d.name;
                }))
                .enter().append("svg:path")
                .attr("d", groupArc)
                .attr("class", function(d) {
                    return "groupArc " + d.name.split('.')[1];
                })
                .style("fill", function(d) {
                    return _this.colors[Math.floor(Math.random() * _this.colors.length)]
                })
                .style("fill-opacity", 0.5)
                // .on("mouseover", _this.mouseon)
                // .on("mouseout", _this.mouseoff);

            _this.svg.selectAll("g.category")
                .data(nodes.filter(function(d){
                    return d.name !== 'participant' && d.name && d.children;
                }))
                .enter().append("svg:g")
                  .attr("class", "category")
                  .attr("id", function(d) { return "node-" + d.key; })
                  .attr("transform", function(d) { 
                    var r=_this.getAngles(d)
                    // console.log(r) // (d.x-100)
                    return "rotate(" + ((d.x - 100)+r.min*3) +") translate(" + (d.y+95) + ")"; })
                .append("svg:text")
                  .attr('class','arcText')
                  .attr("dx", function(d) { return d.x < 180 ? -20 : 20; })
                  .attr("dy", ".31em")
                  .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
                  .attr("transform", function(d) { return /*d.x < 180 ? "rotate(-90)" :*/ "rotate(90)"; })
                  .text(function(d) { return d.name.split('.')[1]; })
                  


        },

        getAngles: function(data) {
            var min,max = 0;
            // console.log('getAnglesInput',data.x)
            if(!data.children) {
                // console.log("Noe kids")
                return { min: 0, max:0 };
            }
            min = max = data.children[0].x;
           data.children.forEach(function(d){
               if(d.x < min) min = d.x;
               if(d.x > max) max = d.x;
           });
            var pi = Math.PI;
            // console.log('minmax return',{ min: min-2 * (pi/180), max: max+2 * (pi/180)});
            return { min: (min-10) * (pi/180), max: (max+10) * (pi/180)};
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
            var _this = this;
            // console.log('debugdata',data)
            _.each(data.players, function(val,iter) {
                _.each(val.hears, function(dat,jter) { // This player hears certain events
                    var i={};
                    i.name = 'participant.' + val.spalla_id + '.' + dat;
                    i.color = _this.colors[Math.floor(Math.random() * _this.colors.length)]
                    i.imports = [];
                    _.each(data.players, function(r) { // Let's check what the others broadcast
                        _.each(r.plays, function(t) { // They play ...
                            if(t === dat) { // If what they play is the same as what we hear...
                                // console.log('pushing up', t, dat)
                                i.imports.push('participant.' + r.spalla_id + '.' + t)
                            }
                        })
                    });

                    map.push(i);
                });
                _.each(val.plays, function(dat,jter) { 
                    var o = {};
                    o.name = 'participant.' + val.spalla_id + '.' + dat;
                    o.imports = [];
                    // _.each(data.players, function(r) { 
                    //     _.each(r.hears, function(t) { 
                    //         if(t === dat) { 
                    //             o.imports.push('participant.' + r.spalla_id + '.' + t)
                    //         }
                    //     })
                    // })
                  map.push(o);
                });
            })
            // console.log('Map', map)
            return map;
        },

        parseEventData: function(data) {
            var map=[];
            var _this = this;

            _.each(data, function(val,key) {
                _this.lastEvent[key] = _this.lastEvent[key] || {};
                //console.log(_this.lastEvent[key].timestamp,val.timestamp)
                if(_this.lastEvent[key].timestamp !== val.timestamp) {
                    map.push(key);
                    _this.lastEvent[key].timestamp = val.timestamp;
                }
            });
            //  console.log(map)
            return map;
        },

        mouseon: function(d) {
            var _this = this;
            console.log('mouseon',d.name)
            _this.svg.selectAll("path.link.target-" + d.name.split('.')[1])
              .classed("target", true)
              .each(_this.updateNodes("source", true));

            _this.svg.selectAll("path.link.source-" + d.name.split('.')[1])
              .classed("source", true)
              .each(_this.updateNodes("target", true));

          // _this.svg.selectAll("groupArc." + d.__data__.name.split('.')[1])
          this.select('path')
              .classed("target", true)
              .attr("fill-opacity",1);
            },
 
        mouseoff:function(d) {
            var _this = this;
            console.log('mouseoff',d);
            _this.svg.selectAll("path.link.source-" + d.name.split('.')[1])
              .classed("source", false)
              .each(_this.updateNodes("target", false));

            _this.svg.selectAll("path.link.target-" + d.name.split('.')[1])
              .classed("target", false)
              .each(_this.updateNodes("source", false));
        },


        updateNodes: function(name, value) {
          var _this = this;
          return function(d) {
            //console.log('updateNotdes',this)
            if (value) this.parentNode.appendChild(this);
            _this.svg.select("#node-" + d[name].key).classed(name, value);
          };
        }

    };

})();
