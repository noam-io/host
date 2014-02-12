


function Player(player){
	this.update(player);
	this.cb = {};
}

Player.prototype.getObj = function(){
	return $("#Channels .table thead tr .player[player-name="+this.spalla_id+"]");
}

Player.prototype.addCB = function(cbName, cb){
	this.cb[cbName] = cb;
}

Player.prototype.createElementCallbacks = function(){
	var self = this;
	self.getObj().click(function(){
		$(".player").removeClass('active');
		if(detailViewManager.toggleLemma(self)){
			self.getObj().addClass('active');	
		}
		activityGraph.displayPlayer(self);
	});
}



Player.prototype.update = function(player){
	var updated = false;
	var updatedPlayHear = 	('hears' in this && this['hears'] != player['hears']) ||
							('plays' in this && this['plays'] != player['plays']);
	console.log(('hears' in this) + " && " + (this['hears'] != player['hears']) + " || "+
				('plays' in this) + " && " + (this['plays'] != player['plays']));
	for(key in player){
		updated = updated || (key in this && this[key] != player[key]);
		this[key] = player[key];
	}
	this.draw();
	if(updated){
		for(cbName in this.cb){
			this.cb[cbName](this);
		}
	}
	if(updatedPlayHear){
		activityGraph.refresh();
	}
}


Player.prototype.doesHear = function(event_name){
	for(name in this.hears){
		if(this.hears[name] == event_name){
			return true;
		}
	}
	return false;
}


Player.prototype.doesPlay = function(event_name){
	for(name in this.plays){
		if(this.plays[name] == event_name){
			return true;
		}
	}
	return false;
}


Player.prototype.toTD = function(){
	return $("<td></td>")
				.attr('player-name', this.spalla_id)
				.addClass('player')
				.html(this.toString());
}

Player.prototype.toString = function(){
	return 	this.spalla_id+"<BR/>"+
            this.device_type+"<BR/>"+
            this.system_version+"<BR/>"+
            this.last_activity;
}


Player.prototype.draw = function(){
	var obj = this.getObj();
	if(obj.size() == 0){
		$("#Channels .table thead tr").append(this.toTD());
		this.createElementCallbacks();
	} else {
		$(obj[0]).html(this.toString());
	}
}