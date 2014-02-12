


function Channel(channel, players){
	this.update(channel, players);
	this.cb = {};
}


Channel.prototype.getObj = function(){
	return $("#Channels .table tbody .channel[channel-name="+this.name+"]");
}


Channel.prototype.addCB = function(name, cb){
	this.cb[name] = cb;
}

Channel.prototype.createElementCallbacks = function(){
	var self = this;
	self.getObj().click(function(){
		$(".channel").removeClass('active');
		if(detailViewManager.toggleTopic(self)){
			self.getObj().addClass('active');
		}
	});
}


Channel.prototype.update = function(channel, players){
	var updated = false;
	for(key in channel){
		updated = updated || (key in this && this[key] != channel[key]);
		this[key] = channel[key];
	}
	if(updated){
		this.draw(players);
		this.highlight();
		activityGraph.addActivity(channel_name);
		for(cbName in this.cb){
			this.cb[cbName](this);
		}
	}
}

Channel.prototype.toTR = function(players){
	var tr = $("<tr></tr>")
				.attr('channel-name', this.name)
				.addClass('channel');

	tr.append($("<td></td>").addClass('name').html(this.name));
	tr.append($("<td></td>").addClass('timestamp').html(this.timestamp));
	tr.append($("<td></td>").addClass('value').html(this.value_escaped));
	for(lemma_id in players){
		var hear = players[lemma_id].doesHear(this.name) ? "H" : "";
		var plays = players[lemma_id].doesPlay(this.name) ? "P" : "";

		tr.append($("<td></td>").addClass(lemma_id).html(hear + plays));
	}
	return tr;
}

Channel.prototype.highlight = function(){
	var obj = $("#Channels .table tbody .channel[channel-name="+this.name+"]");
	if(obj.size() != 0){
		// Clear previous highlight unanimation
		if(this.highlightTimeout){
			clearTimeout(this.highlightTimeout);
		}

		// Animate to highlight
		obj.stop().animate({'background-color': '#FF9'}, 300);
		
		// Set timeout to clear the highlight - this prevents animation queueup but wierd bug with .stop()
		// TODO - Clean this up
		this.highlightTimeout = setTimeout(function(){
			obj.animate({'background-color': '#FFF'}, 300);
		}, 500);
	}
}

Channel.prototype.draw = function(players){
	var self = this;
	var obj = self.getObj();
	if(obj.size() == 0){
		$("#Channels .table tbody").append(this.toTR(players));
		this.createElementCallbacks();
	} else {
		obj = $(obj[0]);
		obj.find('.timestamp').html(this.timestamp);
		obj.find('.value').html(this.value_escaped);

		for(lemma_id in players){
			var hear = players[lemma_id].doesHear(this.name) ? "H" : "";
			var plays = players[lemma_id].doesPlay(this.name) ? "P" : "";
			if(obj.find('.'+lemma_id).size() == 0){
				obj.append($("<td></td>").addClass(lemma_id).html(hear + plays));
			} else {
				obj.find('.'+lemma_id).html(hear + plays);
			}
		}
	}
}