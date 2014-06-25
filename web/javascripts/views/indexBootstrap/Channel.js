//Copyright (c) 2014, IDEO 


var GridDisplaySpeaks = "<span style=\"background-color: #487BA6; color: #EEE; padding: 1px 5px; border-radius: 5px;\">S</span>";
var GridDisplayHears = "<span style=\"background-color: #592685; color: #EEE; padding: 1px 5px; border-radius: 5px;\">H</span>";


function Channel(channel, players){
	this.update(channel, players);
	this.cb = {};
	this.removed = false;
	this.timestamp = new Date().toISOString();
}


Channel.prototype.remove = function(){
	var self = this;
	this.removed = true;
	var obj = self.getObj();
	obj.css({'background-color':'#FFCCCC'});
	obj.delay(300).fadeOut(1000);
	setTimeout(function(){
		obj.remove();
	}, 1300);
}

Channel.prototype.getObj = function(){
	return $("#Channels .table tbody .channel[channel-name="+this.name.replace(/\s+/g, '-')+"]");
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
	var spallas_updated = {};
	for(spalla_id in channel){
		spallas_updated[spalla_id] = false;
		if(this[spalla_id] === undefined) {
			updated = true;
			this[spalla_id] = channel[spalla_id];
		} else {
			for(key in channel[spalla_id]) {
				spallas_updated[spalla_id] = spallas_updated[spalla_id] || (key in this[spalla_id] && this[spalla_id][key] != channel[spalla_id][key]);
				this[spalla_id][key] = channel[spalla_id][key];
			}
			updated = updated  || spallas_updated[spalla_id]
		}
	}
	if(updated){
		this.draw(players);
		this.highlight();
		for(spalla_id in channel){
			if(spallas_updated[spalla_id]) {
				activityGraph.addActivity(channel_name, spalla_id);
			}
		}
		for(cbName in this.cb){
			this.cb[cbName](this);
		}
	} else if(this.timestamp){
			var activity_substring = $.timeago(this.timestamp);
			this.getObj().find('.timestamp').html(activity_substring);
	}
}

Channel.prototype.toTR = function(players){
	var tr = $("<tr></tr>")
				.attr('channel-name', this.name.replace(/\s+/g, '-'))
				.addClass('channel');

	var activity_substring = "";
	if(this.timestamp){
		activity_substring = $.timeago(this.timestamp);
	}
	tr.append($("<td></td>").addClass('name').html(this.name.replace(/\s+/g, '-')));
	tr.append($("<td></td>").addClass('timestamp').html(activity_substring));
	var displayVal = unescape(this.value_escaped);
	var valueTR = $("<td></td>").addClass('dataCellLimited').addClass('value').html(displayVal);
	valueTR.attr('data-trigger', 'hover');
	valueTR.attr('data-placement', 'right');
	valueTR.attr('data-content', displayVal);
	valueTR.popover({container: 'body'});
	tr.append(valueTR);
	var numSH = 0;
	for(lemma_id in players){
		if(players[lemma_id] == null){
			continue;
		}
		var hear = players[lemma_id].doesHear(this.name) ? GridDisplayHears : "";
		var plays = players[lemma_id].doesPlay(this.name) ? GridDisplaySpeaks : "";
		if(hear != "" || plays != ""){
			numSH++;
		}
		tr.append($("<td></td>").addClass(lemma_id.replace(/\s+/g, '-')).hide().fadeIn(1000).html(hear + plays));
	}
	if(numSH > 0){
		return tr;
	} else {
		return null;
	}
}

Channel.prototype.highlight = function(){
	var obj = $("#Channels .table tbody .channel[channel-name="+this.name.replace(/\s+/g, '-')+"]");
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
		var newObject = this.toTR(players);
		if(newObject != null){
			$("#Channels .table tbody").append(newObject);
			this.createElementCallbacks();
		}
	} else {
		obj = $(obj[0]);
		if(this.timestamp){
			obj.find('.timestamp').html($.timeago(this.timestamp));
		}
		var displayVal = unescape(this.value_escaped);
		obj.find('.value').html(displayVal);
		obj.find('.value').attr('data-content', displayVal);
		obj.find('.popover-content').empty().append(displayVal);
		var numPH = 0;
		for(lemma_id in players){
			var hear = players[lemma_id].doesHear(this.name) ? GridDisplayHears : "";
			var plays = players[lemma_id].doesPlay(this.name) ? GridDisplaySpeaks : "";
			if(hear != "" || plays != ""){
				numPH++;
			}
			if(obj.find('.'+lemma_id.replace(/\s+/g, '-')).size() == 0){
				obj.append($("<td></td>").hide().fadeIn(1000).addClass(lemma_id.replace(/\s+/g, '-')).css("display", "table-cell").html(hear + plays));
			} else {
				obj.find('.'+lemma_id.replace(/\s+/g, '-')).css("display", "table-cell").html(hear + plays);
			}
		}
		if(numPH == 0){
			this.remove();
		}
	}
}
