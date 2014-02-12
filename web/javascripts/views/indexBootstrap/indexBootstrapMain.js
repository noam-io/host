$(function() {

  var players = {};
  var channels = {};

  var processManualEventSubmit = function() {
    $.post( this.action, $(this).serialize() );
    $("#play-events").dialog('close');
    return false;
  };

  $("#manual-event-form").submit( processManualEventSubmit );


  $("#sendMessageForm").submit(function(){
    var channel = $("#detailTopic .name").html();
    var value = $(".sendMessageValue").val();

     $.post( '/play-event', {'name': channel, 'value': value}, function(){
      $(".sendMessageValue").val('');
     });
     $("#sendMessage").modal('hide');
     return false;
  });

  var updateAll = function(){
    for(player_name in players){
      players[player_name].draw();
    }
    for(channel_name in channels){
      channels[channel_name].draw(players);
    }
  }

  setInterval(updateAll, 2000);

  var params = {
    divToPopulate: 'real-time-data',
    refreshRoute: '/refresh',
    asyncRefreshRoute: '/arefresh',
    errorMessage: 'Contacting Maestro &hellip;',
    cb: function(results){
      if(results['type'] == 'timeout'){
        return;
      }
      $("#serverDownError").fadeOut(500);
      // Update Player Headings
      var _players = results['players'];
      for(lemma_id in _players){
        if(!(lemma_id in players)){
          players[lemma_id] = new Player(_players[lemma_id]);
        } else {
          players[lemma_id].update(_players[lemma_id]);
        }
      }

      // Update Channel Rows
      var _events = results['events'];
      for(channel_name in _events){
        if(!(channel_name in channels)){
          _events[channel_name]['name'] = channel_name;
          channels[channel_name] = new Channel(_events[channel_name], players); 
        } else {
          channels[channel_name].update(_events[channel_name], players);
        }
      }

      // Refresh detail view
      detailViewManager.refresh();
    },
    errorcb: function(error){
      $("#serverDownError").fadeIn(500);
    }
  };

  var refresher = new NoamRefresher( params );
  refresher.go();

  $(document).ready(function(){
    $('#mainTabs a:last').tab('show');

    activityGraph.init();
  });




});

