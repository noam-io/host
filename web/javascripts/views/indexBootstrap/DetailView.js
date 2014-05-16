//Copyright (c) 2014, IDEO 



var DetailView = function(){
	this.divId = "detailPane";

  this.showView('detailDefault');
  this.activeLemma = null;
  this.activeTopic = null;
	$("#"+this.divId+" .handle").click(this.toggle());
}

DetailView.prototype.showView = function(viewID){
  $("#"+this.divId+" #detailViews > div").hide();
  $("#"+this.divId+" #detailViews #"+viewID).show();
}

DetailView.prototype.toggle = function(){
  var self = this;
  return function(){
    var right = parseInt($("#"+self.divId).attr('pos'));
    if(right == 0){
      self.close();
    } else {
      self.open();
    }
  }
}

DetailView.prototype.open = function(){
  $("#"+this.divId).show();
	$("#"+this.divId+" .handle .dir").html('>');
	$("#"+this.divId).attr('pos', '0');
	$("#"+this.divId).animate({right: 0});
	$("#mainContainer").animate({'padding-right': 400});
}

DetailView.prototype.close = function(){
	$("#"+this.divId+" .handle .dir").html('<');
  $("#"+this.divId).attr('pos', "-400");
  $("#"+this.divId).animate({right: -400});
  $("#mainContainer").animate({'padding-right': 0});
}

DetailView.prototype.refresh = function(){
  if(this.activeLemma != null){
    $("#detailLemma .name").html(this.activeLemma.spalla_id);
    $("#detailLemma .version").html(this.activeLemma.device_type + " - " + this.activeLemma.system_version);
    $("#detailLemma .joinedAt").html("Last activity at " + this.activeLemma.last_activity);
  } else if(this.activeTopic != null){
    $("#detailTopic .name").html(this.activeTopic.name);
    $("#detailTopic .value").html(unescape(this.activeTopic.value_escaped));
  }
}


DetailView.prototype.showLemma = function(lemma){
  this.activeLemma = lemma;
  this.activeTopic = null;
  this.refresh();
  this.showView('detailLemma');
  this.open();
}

DetailView.prototype.showTopic = function(topic){
  this.activeLemma = null;
  this.activeTopic = topic;
  this.refresh();
  this.showView('detailTopic');
  this.open();
}

DetailView.prototype.toggleTopic = function(topic){
  if(topic == this.activeTopic){
    this.close();
    this.activeTopic = null;
  } else {
    this.showTopic(topic);
  }
  return (topic == this.activeTopic);
}

DetailView.prototype.toggleLemma = function(topic){
  if(topic == this.activeLemma){
    this.close();
    this.activeLemma = null;
  } else {
    this.showLemma(topic);
  }
  return (topic == this.activeLemma);
}



var detailViewManager = new DetailView();
