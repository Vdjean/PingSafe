class MessagesController < ApplicationController
  def create
    @ping = Ping.find(params[:ping_id])
    @chat = Chat.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat

    if @message.save
      llm_response = get_llm_response(@message.content, @chat)

      if llm_response.present?
        Message.create(chat: @chat, content: llm_response, role: "assistant")
      end

      redirect_to ping_path(@ping), notice: "Message sent."
    else
      redirect_to ping_path(@ping), alert: "Failed to send message."
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def get_llm_response(user_message, chat)
    llm_chat = RubyLLM.chat

    # Add previous messages as context
    previous_messages = chat.messages.order(:created_at)
    previous_messages.each do |msg|
      role = msg.role || "user"
      if role == "assistant"
        llm_chat.with_instructions(msg.content)
      end
    end

    response = llm_chat.ask(user_message)
    response.content
  rescue => e
    Rails.logger.error "Error getting LLM response: #{e.message}"
    nil
  end
end
