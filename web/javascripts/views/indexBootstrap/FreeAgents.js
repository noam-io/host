

var Guest = function(holdingElementQuery, obj, type){
	this.update(holdingElementQuery, obj, type);
	this.holdingElement = holdingElementQuery;
	this.draw();
	this.type = type;
	this.waiting = false;
	this.storedCB = null;
}

Guest.prototype.getElement = function(){
	var specificType = (this.getClass() != null) ? '.'+this.getClass() : '';
	var queryString = this.holdingElement + " li.lemma_"+this.name.replace(/\s+/g, '-')+specificType;
	return $(queryString);
}

Guest.prototype.remove = function(cb){
	if(this.waiting){
		this.storedCB = cb;
		return;
	}
	if(!cb){
		cb = this.storedCB;
	}
	this.storedCB = null;
	var self = this;
	self.getElement().fadeOut(500);
	setTimeout(function(){
		self.getElement().remove();
		if(cb){
			cb(self.name);
		}
	}, 500);
}

Guest.prototype.setupElementCallbacks = function(){
	var self = this;
	this.getElement().click(function(){
		if(self.type == 'free'){
			self.waiting = true;
			self.update(self.holdingElement, {}, "pending");
			self.getElement().popover('hide');
			$.post('/guests/join', self.name, function(data){
				// Join sent successfully
				setTimeout(function(){
					self.waiting = false;
					self.remove();
				}, 500);
			});
		} else if(self.type == 'owned'){
			if(self.desired_room_name == ''){
				self.waiting = true;
				self.update(self.holdingElement, {}, "freeing");
				self.getElement().popover('hide');
				$.post('/guests/free', self.name, function(data){
					// Free sent successfully
					setTimeout(function(){
						self.waiting = false;
						self.remove();
					}, 500);
				});
			} else {
				return false;
			}
		}
	});
}

Guest.prototype.update = function(holdingElementQuery, obj, type){
	for(key in obj){
		this[key] = obj[key];
	}
	var elem = this.getElement();
	var newHoldingElement = (this.holdingElement != holdingElementQuery);
	this.holdingElement = holdingElementQuery;
	if(type != this.type && this.type != "pending" && this.type != "freeing"){
		elem.removeClass(this.getClass());
		elem.find('.glyphicon').removeClass(this.getIconClass());
		this.type = type;
		this.getElement().popover('hide');
		if(newHoldingElement){
			elem.detach();
			$(this.holdingElement).append(elem);
		}
		elem.addClass(this.getClass());
		elem.find('.glyphicon').addClass(this.getIconClass());
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
				.addClass(this.getClass())
				.addClass('lemma_'+this.name.replace(/\s+/g, '-'))
				.attr('lemma-name', this.name.replace(/\s+/g, '-'))
				.attr('data-trigger', 'hover')
				.attr('data-toggle', 'tooltip')
				.attr('data-title', this.name.replace(/\s+/g, '-'))
				.attr('data-html', 'true')
				.attr('data-content', this.getPopoverContent())
				.append(
					$("<span></span>").addClass('glyphicon').addClass(this.getIconClass()).html(' ')
				)
				.append(
					$("<span></span>").addClass('content').css({'margin-bottom': '-3px'}).html(this.name)
				)
		);
		this.getElement().popover();
		this.setupElementCallbacks();
	}
}

Guest.prototype.getClass = function(){
	if(this.type == 'free'){
		return 'free';
	} else if(this.type == 'owned'){
		if(this.desired_room_name == ''){
			return 'owned';
		} else {
			return 'locked';
		}
	}
	return this.type;
}

Guest.prototype.getIconClass = function(){
	if(this.type == 'free'){
		return 'glyphicon-plus';
	} else if(this.type == "owned"){
		if(this.desired_room_name == ''){
			return 'glyphicon-minus';
		} else {
			return 'glyphicon-paperclip';
		}
	} else if(this.type == "freeing") {
		return "glyphicon-exclamation-sign";
	} else if(this.type == "pending") {
		return "glyphicon-bell";
	}
}


var GuestList = function(opts){
	this.time = 0;
	this.url = opts['url'];
	this.async_url = opts['async_url'];
	this.call_data = opts['call_data'];
	this.interval = null;
	this.run = false;
	this.refresh();
	this.free_agents = {};
	this.your_agents = {};
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
	var data = self.call_data || {};
	data['time'] = self.time;
	$.get(url, data, null)
		.done(function(data){
			self.time = data['time'];
			self.loadContent(data);
			if(cb){
				cb(self);
			}
		})
		.fail(function(err){
			console.log("Failed to update Free Agents. Error: " + err);
		});
}


GuestList.prototype.loadContent = function(data){
	var self = this;
	for(lemmaId in data['guests-free']){
		this.storeAgent(this.freeElementQuery, data['guests-free'][lemmaId], 'free', this.free_agents);
	}

	for(lemmaId in data['guests-owned']){
		this.storeAgent(this.ownedElementQuery, data['guests-owned'][lemmaId], 'owned', this.your_agents);
	}

	var checkValidFreeAgent = function(list_received, list_display){
		return function(){
			var lemma_name = $(this).attr('lemma-name');
			if(!(lemma_name in list_received) && list_display[lemma_name]){
				list_display[lemma_name].remove(function(name){
					delete list_display[name];
				});
			}
		}
	}

	// Remove any expired lemmas
	$(this.ownedElementQuery + " li").each(checkValidFreeAgent(data['guests-owned'], this.your_agents));
	$(this.freeElementQuery + " li").each(checkValidFreeAgent(data['guests-free'], this.free_agents));
}

GuestList.prototype.storeAgent = function(element, obj, type, list){
	if(list[obj['name']]){
		// Already Exists
		list[obj['name']].update(element, obj, type);
	} else {
		// New
		list[obj['name']] = new Guest(element, obj, type);
	}
}



var agentManager = new GuestList({
	'url': "/guests",
	'async_url': "/aguests",
	'freeElementQuery': "#freeAgentList ul",
	'ownedElementQuery': "#ownedAgentList ul"
});
//var ownedAgentManager = new GuestList("#ownedAgentList ul");







