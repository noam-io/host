

var Guest = function(holdingElementQuery, obj, type){
	this.update(holdingElementQuery, obj, type);
	this.holdingElement = holdingElementQuery;
	this.draw();
	this.type = type;
}

Guest.prototype.getElement = function(){
	return $(this.holdingElement + " li.lemma_"+this.name.replace(/\s+/g, '-').toLowerCase());
}

Guest.prototype.setupElementCallbacks = function(){
	var self = this;
	this.getElement().click(function(){
		$.post('/guests/join', self.name, function(data){
			
		});
	});
}

Guest.prototype.update = function(holdingElementQuery, obj, type){
	for(key in obj){
		this[key] = obj[key];
	}
	var elem = this.getElement();
	this.holdingElement = holdingElementQuery;
	if(type != this.type){
		this.type = type;
		elem.detach();
		$(this.holdingElement).append(elem);	
	}
	
}

Guest.prototype.getPopoverContent = function(){
	return $("<div></div>")
		.append(
			$("<table></table")
				.css({width: '300px'})
				.append(
					$("<tr></tr>").html("<td>Desired Room:</td><td>"+this.desired_room_name+"</td>")
				)
				.append(
					$("<tr></tr>").html("<td>IP:</td><td>"+this.ip+"</td>")
				)
				.append(
					$("<tr></tr>").html("<td>Lemma Type:</td><td>"+this.device_type+"</td>")
				)
				.append(
					$("<tr></tr>").html("<td>Version:</td><td>"+this.system_version+"</td>")
			)
		)
		.append(
			$("<div></div>")
				.css({'font-size': '10px'})
				.html("Click on lemma Name to join.")
		)
	.html();
}

Guest.prototype.draw = function(){
	if(this.getElement().size() == 0){
		// Make new
		$(this.holdingElement).append(
			$("<li></li>")
				.addClass('releaseable')
				.addClass('lemma_'+this.name.replace(/\s+/g, '-').toLowerCase())
				.attr('data-trigger', 'hover')
				.attr('data-toggle', 'tooltip')
				.attr('data-title', this.name.replace(/\s+/g, '-').toLowerCase())
				.attr('data-html', 'true')
				.attr('data-content', this.getPopoverContent())
				.html(this.name)
		);
		this.getElement().popover();
		this.setupElementCallbacks();
	}
}


var GuestList = function(opts){
	this.url = opts['url'];
	this.async_url = opts['async_url'];
	this.call_data = opts['call_data'];
	this.interval = null;
	this.run = false;
	this.refresh();
	this.free_agents = {};
	this.freeElementQuery = opts['freeElementQuery'];
	this.ownedElementQuery = opts['ownedElementQuery'];
}

GuestList.prototype.start = function(){
	this.run = true;
	this.arefresh();
}

GuestList.prototype.stop = function(){
	this.run = false;
}

GuestList.prototype.refresh = function(){
	this._refresh(this.url);
}

GuestList.prototype.arefresh = function(){
	this._refresh(this.async_url, function(self){
		self.arefresh();
	});
}

GuestList.prototype._refresh = function(url, cb){
	var self = this;
	if(!url){
		return;
	}
	var time = new Date().getTime();
	$.get(url+"?"+time, self.call_data, null)
		.done(function(data){
			if(data['type'] != 'timeout'){
				self.loadContent(data);
			}
			if(cb){
				cb(self);
			}
		})
		.fail(function(err){
			console.log("Failed to update Free Agents. Error: " + err);
		});
}


GuestList.prototype.loadContent = function(data){
	for(lemmaId in data['guests-free']){
		this.storeAgent(this.freeElementQuery, data['guests-free'][lemmaId], 'free');
	}

	for(lemmaId in data['guests-owned']){
		this.storeAgent(this.ownedElementQuery, data['guests-owned'][lemmaId], 'owned');
	}
}

GuestList.prototype.storeAgent = function(element, obj, type){
	if(this.free_agents[obj['name']]){
		// Already Exists
		this.free_agents[obj['name']].update(element, obj, type);
	} else {
		// New
		this.free_agents[obj['name']] = new Guest(element, obj, type);
	}
}



var agentManager = new GuestList({
	'url': "/guests",
	'async_url': "/aguests",
	'freeElementQuery': "#freeAgentList ul",
	'ownedElementQuery': "#ownedAgentList ul"
});
//var ownedAgentManager = new GuestList("#ownedAgentList ul");







