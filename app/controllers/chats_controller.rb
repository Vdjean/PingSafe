class ChatsController < ApplicationController

  def create
    @ping = Ping.find(params[:ping_id])
    @chat = Chat.new
    @chat.ping = @ping
    if @chat.save
      redirect_to ping_path(@ping), notice: "Chat created."
    else
      redirect_to ping_path(@ping), alert: "Failed to create chat."
    end
  end
end
