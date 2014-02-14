(function () {
    'use strict';

    window.graphView = {
    	el: '.graph',
        div: null,
        d: {
            w: 1140,
            h: 960,
            rx: 1140/3,
            ry: 1140/3
        },
        d3: null,
        bundle: null,
        cluster: null,
        line: null,
        svg: null,
        colors:[ '#210050','#46007a','#7f00de','#018b88','#01b8b1','#01ead6','#1667af','#01aeff','#6ed1ff','#73115b','#af007c','#d03593' ],
        fakeData: 'javascripts/data/dummy.json',

        init: function(data){
            var _this = this;

            console.log('started graphview')

            _this.setupGraph();
            _this.parseToD3(data);
            _this.render();

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
                .tension(.35)
                .radius( function(d) {
                    return d.y;
                    })
                .angle( function(d) {
                    return d.x/180 * Math.PI;
                    });

            // Generates the containing div
            this.div = d3.select('.graph')
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

            // Line generator
            this.line = d3.svg.line.radial()
                .interpolate("bundle")
                .tension(.25)
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

                console.log('mappedData',d);
                console.log('nodes',nodes);
                console.log('links',links);
                console.log('splines',splines);
 
                _this.drawCategory(nodes);

                 // Establish paths from links
                var path = _this.svg.selectAll("path.link")
                    .data(links)
                    .enter().append("svg:path")
                    .attr("class", function(d) { return "link name-" + d.source.name.split('.')[1] + " source-" + d.source.name.split('.')[1] + " target-" + d.target.name.split('.')[1]; })
                    .attr("d", function(d, i) { return _this.line(splines[i]); });

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
                      .text(function(d) { return d.name.split('participant.')[1]; })
                      .on("mouseover", _this.mouseon)
                      .on("mouseout", _this.mouseoff);                
          // });
        },


        drawCategory: function(nodes) {
            var _this = this;

            // Set up groups 
            var groups = this.svg.selectAll("g.group")
              .data(nodes.filter(function(d) {
                 console.log("categoryNodeFilter",d);
                 return d.x ? d : null && d.children && d.key !== 'participant' && d.name.split('.').length == 2
             }))
            .enter().append("group")
              .attr("class", "group");
              

            
            // Arc Generator
            var groupArc = d3.svg.arc()
                .innerRadius(this.d.ry-120)
                .outerRadius(this.d.ry-160)
                .startAngle(function(d){ var r=_this.getAngles(d.__data__); return r.min; })
                .endAngle(function(d){ var r=_this.getAngles(d.__data__); return r.max; });

        
          this.svg.selectAll("g.arc")
            .data(groups[0].filter(function(d){
                return d.__data__.name !== 'participant';
            }))
            .enter().append("svg:path")
            .attr("d", groupArc)
            .attr("class", function(d) {
                return "groupArc " + d.__data__.name.split('.')[1];
            })
            .style("fill", function(d) {
                return _this.colors[Math.floor(Math.random() * _this.colors.length)]
            })
            .style("fill-opacity", 0.5)
            .on("mouseover", _this.mouseon)
            .on("mouseout", _this.mouseoff);

            // this.svg.selectAll('text')
            //     .data( function(d, i) { return d.__data__.name !== 'participant'; })
                // .enter().append('text')
                // .attr('text', function(d) { return d.__data__.key })


            // var arc_and_text = this.svg.selectAll("g.arc")
            //     .data(groups[0].filter(function(d){
            //     return d.__data__.name !== 'participant';
            // }))
            //     .enter().append("svg:g")
            //     .attr("class","arc_and_text");

            // var arc_path = arc_and_text.append("svg:path")
            //     .attr("d", groupArc)
            //     .attr("class", "groupArc")
            //     .attr("id", function(d, i) { return "arc" + i; })
            //     .style("fill", "#1f77b4")
            //     .style("fill-opacity", 0.5); //MH: (d.__data__.key) gives names of groupings

            // var arc_text = arc_and_text.append("text")
            //     .attr("class","arc_text")
            //     .attr("x", 3)
            //     .attr("dy", 15);

            // arc_text.append("textPath")
            //     .attr("xlink:href", function(d, i) { return "#arc" + i; })
            //     .attr("class","arc_text_path")
            //     .style("fill","#ffffff")
            //     .text(function(d, i) { return d.__data__.key; });

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
            console.log('debugdata',data)
            _.each(data.players, function(val,iter) {
                var i={}, o={};
                i.name = 'participant.' + val.spalla_id + '.hears';
                i.size = Math.random() * 5000;
                i.color = _this.colors[Math.floor(Math.random() * _this.colors.length)]
                i.imports = [];
                _.each(val.hears, function(dat,jter) {
                    i.imports.push('participant.' + dat.split('sentFrom')[1] + '.plays');
                });

                o.name = 'participant.' + val.spalla_id + '.plays';
                o.color = _this.colors[Math.floor(Math.random() * _this.colors.length)]
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
            var _this = this;
            //console.log('mouseon',d.name)
            _this.svg.selectAll("path.link.target-" + d.__data__.name.split('.')[1])
              .classed("target", true)
              .each(_this.updateNodes("source", true));

            _this.svg.selectAll("path.link.source-" + d.__data__.name.split('.')[1])
              .classed("source", true)
              .each(_this.updateNodes("target", true));

          // _this.svg.selectAll("groupArc." + d.__data__.name.split('.')[1])
          this.select('path')
              .classed("target", true)
              .attr("fill-opacity",1);
            },
 
        mouseoff:function(d) {
            var _this = this;
            _this.svg.selectAll("path.link.source-" + d.__data__.name.split('.')[1])
              .classed("source", false)
              .each(_this.updateNodes("target", false));

            _this.svg.selectAll("path.link.target-" + d.__data__.name.split('.')[1])
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

    };

})();
