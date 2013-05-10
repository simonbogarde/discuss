require_dependency 'discuss/application_controller'

module Discuss
  class MessagesController < ApplicationController
    before_action :message, only: [:show, :update, :destroy]

    def new
      @message = discuss_current_user.messages.new
    end

    def show
      redirect_to edit_message_path(message) unless message.received? || message.sent?
    end

    def create
      @message = Message.create(message_params.merge(user: discuss_current_user))
      send_message
    end

    def reply
      @message = Message.find(params[:message_id])
      @message.reply! message_params.merge(user: discuss_current_user)
      redirect_to mailbox_path(:inbox), notice: 'Reply sent'
    end

    def edit
      redirect_to message unless message.unsent?
    end

    def update
      message.update(message_params)
      send_message
    end

    def trash
      @message = Message.find(params[:message_id])
      @message.trash!
      redirect_to mailbox_path(:inbox), notice: 'Message moved to trash'
    end

    def destroy
      message.delete!
      redirect_to mailbox_path(:inbox), notice: 'Message deleted'
    end

    private
    def message
      @message ||= Message.find(params[:id])
    end
    helper_method :message

    def message_params
      params.require(:message).permit(:subject, :body, :draft, draft_recipient_ids: [])
    end

    def send_message
      message.send!
      notice = message.sent? ? 'Yay!, Message sent' : 'Draft saved'
      redirect_to mailbox_path(:inbox), notice: notice
    end
  end
end
