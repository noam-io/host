//Copyright (c) 2014, IDEO 

var GraphicActivity = function(){
	this.duration = 45;
    this.now = new Date(Date.now() - this.duration);
    this.width = 400;
	this.height = 400;
	this.topics = [];
	this.topicLookupByName = {};
	this.viewTopicsPlays = [];
	this.viewTopicsHears = [];
}

GraphicActivity.prototype.displayPlayer = function(player){
	this.viewTopicsPlays = player.plays;
	this.viewTopicsHears = player.hears;
	this.refresh();
}

GraphicActivity.prototype.refresh = function(){
	this.svg.selectAll(".label").remove();
	this.svg.selectAll(".topic").remove();
}

GraphicActivity.prototype.init = function(){
	var self = this;
	var margin = {top: 12, right: 0, bottom: 20, left: 40};

	this.x = d3.time.scale()
	    .domain([this.now - this.duration * 1000, this.now])
	    .range([0, this.width - 100]);

	this.svg = d3.select("#activityGraph").append("p").append("svg")
	    .attr("width", this.width + margin.left + margin.right)
	    .attr("height", this.height + margin.top + margin.bottom)
	    .style("margin-left", -margin.left + "px")
	    .append("g")
	    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	this.svg.append("defs").append("clipPath")
	    .attr("id", "clip")
	    .append("rect")
	    .attr("width", this.width)
	    .attr("height", this.height);

	this.axis = this.svg.append("g")
	    .attr("class", "x axis")
	    .attr("stroke-width", "1")
	    .attr("transform", "translate(0," + 15 + ")")
	    .call(self.x.axis = d3.svg.axis().scale(self.x).orient("top"));

	var self = this;
	setInterval(function(){
		self.tick();
	}, this.duration);
}

GraphicActivity.prototype.addActivity = function(topic){
	if(!(topic in this.topicLookupByName)){
		this.topics.push({
			'data': [],
			'name': topic
		});
		this.topicLookupByName[topic] = this.topics.length - 1;
	}

	this.topics[this.topicLookupByName[topic]]['data'].push({t: new Date()});
}

GraphicActivity.prototype.drawTopic = function(topicDisplayHeight, topic, type){
	var self = this;
	if(!(topic in this.topicLookupByName)){
		return 0;
	}

	var topicI = this.topicLookupByName[topic];

	while(self.topics[topicI]['data'].length > 0 && self.topics[topicI]['data'][0].t < self.x.domain()[0]){
		self.topics[topicI]['data'].splice(0, 1);
		self.svg.select(".topic-"+topicI).remove();
	}

	self.svg.selectAll(".topic-"+topicI)
		.data(self.topics[topicI]['data'])
		.enter().append("svg:line")
		.attr("class", "topic topic-"+topicI+" " + type)
		.attr("x1", function(d, i) { return self.x(d.t); })
		.attr("y1", function(d, i) { return 30 + topicDisplayHeight * 20; })
		.attr("x2", function(d, i) { return self.x(d.t); })
		.attr("y2", function(d, i) { return 30 + topicDisplayHeight * 20 + 10 })
		.attr("transform", function(d){
			//return "translate(" + -(self.x(self.x.domain()[1]) - self.x(d.t)) + ")"
		});
	return 1;
}

GraphicActivity.prototype.tick = function(){
	var self = this;

	var labels = [];
	var topicDisplayNum = 0;

	for(hearTopic in self.viewTopicsHears){
		labels.push(self.viewTopicsHears[hearTopic]);
		topicDisplayNum += self.drawTopic(topicDisplayNum, self.viewTopicsHears[hearTopic], 'topic-hear');
	}
	for(playsTopic in self.viewTopicsPlays){
		labels.push(self.viewTopicsPlays[playsTopic]);
		topicDisplayNum += self.drawTopic(topicDisplayNum, self.viewTopicsPlays[playsTopic], 'topic-play');
	}

	// Set side labels
	self.svg.selectAll(".label")
		.data(labels)
		.enter().append("svg:text")
		.attr('class', 'label')
		.attr('x', function(){ return self.x.range()[1] + 10; })
		.attr('y', function(d, i){
			return 30 + i * 20 + 8;
		})
		.attr('class', 'label')
		.text(function(txt){
			return txt;
		});


	// update the domains
	self.now = new Date();
	self.x.domain([self.now - self.duration * 1000, self.now]);

	self.svg.selectAll(".topic")
		.attr("x1", function(d, i) { return self.x(d.t); })
		.attr("x2", function(d, i) { return self.x(d.t); })

	// slide the x-axis left
	self.axis.transition()
		.duration(self.duration)
		.ease("linear")
		.call(self.x.axis);
}

var activityGraph = new GraphicActivity();
