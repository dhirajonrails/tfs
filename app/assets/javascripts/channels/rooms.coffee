# App.global_chat = App.cable.subscriptions.create {
#     channel: "ChatRoomsChannel"
#     type: 'merchant'
#   },
#   connected: ->
#     console.log 'connected'
#     # Called when the subscription is ready for use on the server

#   disconnected: ->
#     console.log 'disconnected'
#     # Called when the subscription has been terminated by the server

#   received: (data) ->
#     console.log data

#   send_message: ->
#     console.log 'called send message'
#     @perform 'send_message'


# $('#userRegisterForm').on 'submit', (e) ->
#   App.global_chat.send_message
#   e.prevenDefault
