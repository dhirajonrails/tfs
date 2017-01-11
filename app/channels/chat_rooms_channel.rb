# # Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
# class ChatRoomsChannel < ApplicationCable::Channel
#   def subscribed
#     stream_from "transactions_#{params[:type]}_channel"
#   end

#   def unsubscribed
#     # Any cleanup needed when channel is unsubscribed
#   end

#   def send_message(data)
#     logger.info 'called send_message'
#   end
# end
