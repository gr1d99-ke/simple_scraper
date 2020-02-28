App.links_extraction = App.cable.subscriptions.create "LinksExtractionChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    document.getElementById("links-count").innerHTML = data['count'];
    # Called when there's incoming data on the websocket for this channel
