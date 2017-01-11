# class MessageBroadcastJob < ApplicationJob
#   queue_as :default

#   def perform(message)
#     ActionCable.server.broadcast "transactions_admin_channel",
#                                  total: Transaction.sum(:amount)
#   end

#   private

#   def render_message(message)
  	
#     # MessagesController.render partial: 'messages/message', locals: {message: message}
#   end
# end