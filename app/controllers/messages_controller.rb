class MessagesController < ApplicationController

  def create
    @chat = Chat.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    if @message.save
      redirect_to chat_path(@chat), notice: "Message sent."
    else
      redirect_to chat_path(@chat), alert: "Failed to send message."
    end
  end

  private
  def message_params
    params.require(:message).permit(:content)
  end
end
