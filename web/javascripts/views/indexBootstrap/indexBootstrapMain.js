//Copyright (c) 2014, IDEO 

$(function() {

  var players = {};
  var channels = {};
  window.numberOfPlayers = 0;
  window.numberOfPlayedMessages = 0;
  window.serverUp = false;

  var processManualEventSubmit = function() {
    $.post( this.action, $(this).serialize() );
    $("#play-events").dialog('close');
    return false;
  };

  $("#manual-event-form").submit( processManualEventSubmit );


  $("#sendMessageForm").submit(function(){
    var channel = $("#detailTopic .name").html();
    var value = $(".sendMessageValue").val();

     $.post( '/play-event', {'name': channel, 'value': value}, function(data){
        $(".sendMessageValue").val('');
     });
     $("#sendMessage").modal('hide');
     return false;
  });

  var updateAll = function(){
    if(window.serverUp){
      for(player_name in players){
        players[player_name].draw();
      }
      for(channel_name in channels){
        channels[channel_name].draw(players);
      }
    }
  }

  setInterval(updateAll, 1000);

  var params = {
    divToPopulate: 'real-time-data',
    refreshRoute: '/refresh',
    asyncRefreshRoute: '/arefresh',
    errorMessage: 'Contacting Maestro &hellip;',
    cb: function(results){
      window.serverUp = true;
//    console.log('cursize',window.numberOfPlayers)
//    console.log('newsize',_.size(results['players']));

      if((_.size(results['players']) !== window.numberOfPlayers) || (results['number-played-messages'] !== window.numberOfPlayedMessages)) {
        $('.graph').html('');
        window.numberOfPlayers = _.size(results['players']);
        window.numberOfPlayedMessages = results['number-played-messages'];
        if(window.numberOfPlayers > 0) {
          window.graphView.init(results);
        }
      } else {
        window.graphView.update(results['events']);
      }

      $("#serverDownError").fadeOut(500);
      // Update Player Headings
      var _players = results['players'];
      var updateChannels = false;
      for(lemma_id in _players){
        if(!(lemma_id in players)){
          players[lemma_id] = new Player(_players[lemma_id]);
          updateChannels = true;
        } else {
          players[lemma_id].update(_players[lemma_id]);
        }

        // Ensures all channels are added to grid even if no activity
        var allChannels = players[lemma_id].hears.concat(players[lemma_id].plays);
        allChannels.map(function(value){
          if(!(value in channels)){
            channels[value] = new Channel({'name' : value }, players); 
          }
        });
      }

      $("#Channels .table thead tr .player").each(function(){
        var name = $(this).attr('player-name');
        if(!(name in _players)){
          if(name in players){
            players[name].remove();
            delete players[name];
          }
        }
      });

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

      for(channelName in channels){
        if(channels[channelName].removed){
          delete channels[channelName];
        } else if(updateChannels){
          channels[channelName].draw(players);
        }
      }

      // Refresh detail view
      detailViewManager.refresh();
    },
    errorcb: function(error){
      window.serverUp = false;
      for(channelName in channels){
        channels[channelName].remove();
        delete channels[channelName];
      }
      for(playerName in players){
        players[playerName].remove();
        delete players[playerName];
      }
      $("#serverDownError").fadeIn(500);
    }
  };

  var refresher = new NoamRefresher( params );
  refresher.go();

  $(document).ready(function(){
    $('#mainTabs a:last').tab('show');
    $('.dropdown-menu').click(function(){
      event.stopPropagation();
      return false;
    });
    $('.scrollArea li').popover();
    activityGraph.init();
    agentManager.start();




    // Renaming Server
    $("#renameServer").submit(function(){
      var name = $("#renameServer input[type=text]").val();
      $.post('/settings', {'name': name}, function(data){
        updateFromSettings(data);
      });
      return false;
    });

    $.get('/settings', null, null)
      .done(function(data){
        updateFromSettings(data);
      })
      .fail(function(err){
        console.log("Error: ");
        console.log(err);
      });

    $("#powerButtonContainer").click(function(){
      var setTo =  !$("#powerButtonContainer .power").hasClass('active');
      $.post('/settings', {'on': setTo}, function(data){
        updateFromSettings(data);
      });
    });

    $("#welcomeScreenSubmit").submit(function(){
      var name = $("#newservername").val();
      if(name.length > 0){
        $.post('/settings', {'name': name, 'on': true}, function(data){
          if(data['name'] == name){
            updateFromSettings(data);
            $("#defaultWelcomeScreen").fadeOut(100);
          }
        });
      }
      return false;
    })

    function updateFromSettings(data){
      $(".server-name-value").html(data['name']);
      $("#inutRoomName").val(data['name']);
      if(data['name'].length > 0){
        $("#defaultWelcomeScreen").fadeOut(300);
      }
      if(data['on']){
        $("#powerButtonContainer .power").addClass('active');
      } else {
        $("#powerButtonContainer .power").removeClass('active');
      }
    }


  });




});

