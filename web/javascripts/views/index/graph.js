(function () {
    'use strict';

    window.graphView = {
    	el: '.graph',
        div: null,
        d: {
            w: $(window).height()*.88,
            h: $(window).height()*.88,
            rx: $(window).height()*.44,
            ry: $(window).height()*.44,
            overlayPadding: $(window).height()*.2
        },
        d3: null,
        lastEvent: [],
        bundle: null,
        cluster: null,
        line: null,
        svg: null,
        timer: null,
        colors:[ '#210050','#46007a','#7f00de','#018b88','#01b8b1','#01ead6','#1667af','#01aeff','#6ed1ff','#73115b','#af007c','#d03593' ],
        lemmaToColor: [],
        fakeData: 'javascripts/data/dummy.json',

        init: function(data){
            var _this = this;

            // console.log('started graphview')

            _this.setupGraph();
            _this.parseToD3(data);
            _this.render();

            _.bindAll(window.graphView,'hoverLemma','clickLemma','hoverOffLemma');

        },

        render: function(){
            
            

        },	

        update: function(eventData) {
            var _this = this;
            var d = this.parseEventData(eventData);

            _.each(d,function(val,key){
                // console.log(val)
                var select = _this.svg.selectAll("path.link.target-" + val)
                  .each(_this.updateNodes("source", true))
                  .transition()
                    .style("opacity", 1)
                    .style('stroke-width','3px')
                    .attr("stroke", function(d) { return _this.getColor(d.target.parent)})
                    .duration(400);

                select.transition()
                    .style("opacity", .1)
                    .style('stroke-width','2px')
                    .attr("stroke", "black")
                    .duration(400)
                    .delay(400);
                
                // Highlight sender
                var sender = _this.svg.selectAll('.source#node-' + val)
                    // .each(_this.updateNodes("source", true))
                  .transition()
                    .style("opacity", 1)
                    // .style('font-size','10pt')
                    .duration(400);


                sender.transition()
                     .style("opacity", .4)
                    // .style('font-size','10pt')
                    .duration(400)
                    .delay(400);


                // Highlight receiver
                var receiver = _this.svg.selectAll('.target#node-' + val)
                    // .each(_this.updateNodes("source", true))
                  .transition()
                    .style("opacity", 1)
                    // .style('font-size','10pt')
                    .duration(400);


                receiver.transition()
                     .style("opacity", .4)
                    // .style('font-size','10pt')
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
                })
                .separation(function(a,b){
                  return 1;//(a.parent == b.parent ? 1 : 2) / a.depth;
                });

            // Setup the layout bundle
            this.bundle = d3.layout.bundle();

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
                .tension(.0)
                .radius(function(d) { return d.y - 52; })
                .angle(function(d) { return d.x / 180 * Math.PI; });

            
        },


        // animate path from source to destination
        animatePaths: function() {
          // var test = document.querySelector('.connector');

          var testNodes = document.querySelectorAll('.connector');

          for (var node=0; node<testNodes.length; node++) {

            var length = testNodes[node].getTotalLength();
            // Clear any previous transition
            testNodes[node].style.transition = testNodes[node].style.WebkitTransition = 'none';
            // Set up the starting positions
            testNodes[node].style.strokeDasharray = length + ' ' + length;
            testNodes[node].style.strokeDashoffset = length;
            // Trigger a layout so styles are calculated & the browser
            // picks up the starting position before animating
            testNodes[node].getBoundingClientRect();
            // Define our transition
            testNodes[node].style.transition = testNodes[node].style.WebkitTransition = 'stroke-dashoffset .5s ease-in-out';
            // Go!
            testNodes[node].style.strokeDashoffset = '0';

          }

        },


        parseToD3: function(collectionData) {
            var _this = this;
            // d3.json(collectionData, function(data) {

            // Main elements
            // HERE BE DRAGONS!!!
            // Data munging.    
            var d = _this.mapToNodes(collectionData),
                nodes = _this.cluster.nodes(_this.mapHierarchy(d)),
                links = _this.getConnections(nodes),
                splines = _this.bundle(links);

          // console.log('mappedData',d);
          // console.log('nodes',nodes);
          // console.log('links',links);
          // console.log('splines',splines);

            _this.drawCategory(nodes);

             // Establish paths from links
            var path = _this.svg.selectAll("path.link")
                .data(links)
                .enter().append("svg:path")
                .attr("class", function(d) { return "connector link name-" + d.source.name.split('.')[2] + " source-" + d.source.name.split('.')[2] + " target-" + d.target.name.split('.')[2]; })
                .attr("stroke", function(d) {return _this.getColor(d.target.parent)})
                .attr("stroke-width", 4)
                .attr("d", function(d, i) { 
                    // console.log(d);
                    return  _this.line(splines[i]); 
                })
                .on("mouseover", _this.hoverLine)
                .on("mouseout", _this.hoverOffLine)
                .on("click", _this.clickLine);

                // this.svg.append("svg:path")
                //   .attr("class", "arc")
                //   .attr("d", d3.svg.arc().outerRadius(this.d.ry - 120).innerRadius(0).startAngle(Math.PI).endAngle(2 * Math.PI))


            _this.animatePaths();    


                // Establish nodes for text display
            var textGroup = _this.svg.selectAll("g.node")
                  .data(nodes.filter(function(d) { return !d.children; }))
                .enter().append("svg:g")
                  .attr("class", "node")
                  .attr("class", function(d) {
                    return d.output ? "source" : "target";
                  })
                  .attr("id", function(d) { return "node-" + d.key; })
                  .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; })


            textGroup.append("svg:text")
                  .attr("dx", function(d) { return d.x < 180 ? 8 : -8; })
                  .attr("dy", ".31em")
                  .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
                  .attr("transform", function(d) { return d.x < 180 ? null : "rotate(180)"; })
                  .text(function(d) { return d.name.split('.')[2]; })
                  .on("mouseover", _this.hoverTopic)
                  .on("mouseout", _this.hoverOffTopic)
                  .on("click", _this.clickTopic)


            textGroup.append('svg:path')
                      .attr('d', function(d) { 
                        var x = 37, y = 0, size=10;
                        if (d.output)
                          return 'm -'+x+' '+y+' l 0 '+size+' l -'+size+' -'+size+' l '+size+' -'+size+''
                        else
                          return 'm -' + (x+5) + ' '+y+' l 0 '+size+' l '+size+' -'+size+' l -'+size+' -'+size+''
                      })
                      .attr("style", function(d) { 
                        if (d.output)
                         return "fill:"+_this.getColor(d);
                        else
                         return "fill: #fff";

                      })

            _this.drawHoverArcs(nodes);          

          // });
        },


        // Calculates single-line arc length to be used for text alignment along arcs
        getArcLength: function() {


        },


        // Categories are the big block arcs that contain targets
        drawCategory: function(nodes) {
            var _this = this;
            var innerPadding = 120;
            var outerPadding = 160;
            var textPathPadding = 145;
            
            var numOfNodes = (nodes.filter(function(d) {
              return !d.children && d.parent;
            })).length;

            // Arc Generator
            var groupArc = d3.svg.arc()
                .innerRadius(this.d.ry-innerPadding)
                .outerRadius(this.d.ry-outerPadding)
                .startAngle(function(d){ var r=_this.getAngles({data: d, nodeLength: numOfNodes}); return r.min; })
                .endAngle(function(d){ var r=_this.getAngles({data: d, nodeLength: numOfNodes}); return r.max; });

            // Text arc generator, go not where we have gone, lest ye emerge a madman - Ethan
             // Arc Generator
            var textArc = d3.svg.arc()
                .innerRadius(this.d.ry-textPathPadding)
                .outerRadius(this.d.ry-textPathPadding)
                .startAngle(function(d){ var r=_this.getAngles({data: d, nodeLength: numOfNodes}); return r.min; })
                .endAngle(function(d){ var r=_this.getAngles({data: d, nodeLength: numOfNodes}); return r.max; });


            this.svg.selectAll("g.arc")
                .data(nodes.filter(function(d){
                    // return d.name !== 'participant' && d.name;
                    return d.depth == 2 && d.name;
                }))
                .enter().append("svg:path")
                .attr("d", groupArc)
                .attr("class", function(d) {
                    return "groupArc " + d.name.split('.')[1];
                })
                .style("fill", function(d) {
                     return _this.getColor(d);
                })
                .style("fill-opacity", 1.);
                // .on("mouseover", function(d) {
                //   d3.select(this)
                //     .transition()
                //       .duration(500)
                //       .attr('transform', 'scale(1.1)')
                //   console.log('hey');
                // });


            this.svg.selectAll("g.arc2")
                .data(nodes.filter(function(d){
                    // return d.name !== 'participant' && d.name;
                    return d.depth == 2 && d.name;
                }))
                .enter().append("svg:path")
                .attr("d", textArc)
                .attr("id", function(d) {
                    return "groupArcId_" + d.name.split('.')[1];
                })
                .style("fill-opacity", 0.0);


           _this.svg.selectAll("g.category")
                .data(nodes.filter(function(d){
                    return d.name !== 'participant' && d.name && d.children;
                }))
                .enter().append("svg:text")
                  .attr("class","category")
                  .attr("text-anchor", "left")
                  .attr('fill', 'white')
                  .attr("id", function(d) { return "node-" + d.key; })
                .append("svg:textPath")
                  .attr('startOffset', '5px')
                  .attr("xlink:href", function(d) {return "#groupArcId_" + d.name.split('.')[1]})
                  // .text(function(d) { return d.name.split('.')[1] + ' - ' + d.children[0].type; }) // <-- Shaky motherfuckin edifice right here
                  .text(function(d) { return d.name.split('.')[1]; })

        },


        // Draw transparent arcs that overlay the lemma arcs. This creates hover zones.
        drawHoverArcs: function(nodes) {
            var _this = this;
            var innerPadding = 110;
            var outerPadding = 170;
            var textPathPadding = 145;
            
            var numOfNodes = (nodes.filter(function(d) {
              return !d.children && d.parent;
            })).length;

            // Arc Generator for the hover arcs overlaying each lemma
            var hoverArc = d3.svg.arc()
                .innerRadius(this.d.ry-innerPadding)
                .outerRadius(this.d.ry-outerPadding)
                .startAngle(function(d){ var r=_this.getAngles({data: d, nodeLength: numOfNodes}); return r.min; })
                .endAngle(function(d){ var r=_this.getAngles({data: d, nodeLength: numOfNodes}); return r.max; });

            this.svg.selectAll("g.hover_arc")
                .data(nodes.filter(function(d){
                    //return d.name !== 'participant' && d.name;
                    return d.depth == 2 && d.name;
                }))
                .enter().append("svg:path")
                .attr("d", hoverArc)
                .attr("class", function(d) {
                    return "hoverArc " + d.name.split('.')[1];
                })
                .style("fill-opacity", 0)
                .on("click", _this.clickLemma);
                // .on("mouseover", _this.hoverLemma)
                // .on("mouseleave", _this.hoverOffLemma);

        },        


        // assumed arguments {data: d, nodeLength: numOfNodes}
        getAngles: function(args) {
            var data = args.data;

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
            
            // var buffer = the more nodes, the smaller the buffer
            // var sliceOfPie = (total number of nodes / 360) - artificial gap between each node

            var sliceOfPie = ((360 / args.nodeLength) -2 ) / 2; 
            // console.log('sliceOfPie: ' + sliceOfPie);
            // console.log('args.nodeLength: ' + args.nodeLength);


            // console.log('minmax return',{ min: min-2 * (pi/180), max: max+2 * (pi/180)});
            return { min: (min-sliceOfPie) * (pi/180), max: (max+sliceOfPie) * (pi/180), middle:(max+min)/2 };
        },

        // This function consumes a node and returns the color of the lemma
        getColor: function(node) {
          var color, search;
          if(node.depth < 2) return "red";
          if(node.depth >= 2) search = node.name.split('.')[1];
          color = _.findWhere(this.lemmaToColor, {'key':search});
          if(typeof color === 'undefined') {
            var iter = Math.floor(Math.random() * this.colors.length);
            color = this.colors[this.lemmaToColor.length%this.colors.length];
            this.lemmaToColor.push({'key':search, 'color': color})
            // console.log("Adding a new color for ", search )
          } else {
            color = color.color
          }
          // console.log(search,'color:',color)
          return color;
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
            // console.log(imports)
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
                    i.type = val.device_type;
                    i.color = _this.colors[Math.floor(Math.random() * _this.colors.length)];
                    i.version = val.system_version,
                    i.lastActive = val.last_activity
                    i.output = false;
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
                    o.output = true;
                    o.type = val.device_type;
                    o.color = _this.colors[Math.floor(Math.random()*_this.colors.length)]
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

        updateNodes: function(name, value) {
          var _this = this;
          return function(d) {
            // console.log('updateNodes',name,value)
            if (value) this.parentNode.appendChild(this);
            // _this.svg.select("#node-" + d[name].key).classed(name, value);
          };
        },

        // Arc, i.e. categories
        hoverLemma: function(d) {
          var _this = window.graphView;
          var $overlay = $('.lemma-overlay');

          $overlay.css({
            width: _this.d.ry-_this.d.overlayPadding,
            marginTop: _this.d.ry/2 + 30
          })

          $overlay.find('.header')
            .css('background', _this.getColor(d))
            .html(d.name);

          $overlay.find('.type').html(d.children[0].type);
          
          $overlay.find('.last-active').html(function(){
            var s = null;
            // _.each() is a syncronous function (supposedly)
            _.each(d.children, function(val,i) {
              var t = val.lastActive;
              if(!s) s=new Date(String(t).replace("T"," "));
              else s = new Date(String(t).replace("T"," ")) > s ? new Date(String(t).replace("T"," ")) : s;
            })
            return  "Last Active: "  + s.toLocaleTimeString();
          });

          $overlay.find('.hear').html(function(){
            var s = "";
            _.each(d.children, function(val,i) {
              if(val.output) return;
              s += (val.key + " "); 
            })
            return s;
          });

          $overlay.find('.say').html(function(){
            var s = "";
            _.each(d.children, function(val,i) {
              if(!val.output) return;
              s += (val.key + " "); 
            })
            return s;
          });
          $overlay.fadeIn(150);
        },

        hoverOffLemma: function(d) {
            console.log('hover off lemma',d);
            $('.lemma-overlay').fadeOut(50);
        },

        clickLemma: function(d) {
            console.log('click lemma',d);
        },

        // Topics, i.e. node renders
        hoverTopic: function(d) {
            var _this = this;
            console.log('hover topic',d)
            window.graphView.svg.selectAll("path.link.target-" + d.name.split('.')[2])
              .classed("target", true)
              // .each(_this.updateNodes("source", true));

            window.graphView.svg.selectAll("path.link.source-" + d.name.split('.')[2])
              .classed("source", true)
        },

        hoverOffTopic: function(d) {
            var _this = this;
            console.log('hover off topic',d);
            window.graphView.svg.selectAll("path.link.source-" + d.name.split('.')[2])
              .classed("source", false)
              // .each(_this.updateNodes("target", false));

            window.graphView.svg.selectAll("path.link.target-" + d.name.split('.')[2])
              .classed("target", false)
        },

        clickTopic: function(d) {
            console.log('click topic',d);
        },

        // Lines between nodes
        hoverLine: function(d) {
            console.log('hover on line',d);
        },

        hoverOffLine: function(d) {
            console.log('hover off line',d);
        },

        clickLine: function(d) {
            console.log('click line',d);

        }





    };

})();
