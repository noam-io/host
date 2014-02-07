


function Player(player){
	this.update(player);
}

Player.prototype.update = function(player){
	for(key in player){
		this[key] = player[key];
	}
	this.draw();
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
	var obj = $("#Channels .table thead tr .player[player-name="+this.spalla_id+"]");
	if(obj.size() == 0){
		$("#Channels .table thead tr").append(this.toTD());
	} else {
		$(obj[0]).html(this.toString());
	}
}