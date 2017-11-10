# frozen_string_literal: true

module Decidim
  module Messaging
    # The controller to handle the user's chats.
    class ChatsController < Decidim::ApplicationController
      include FormFactory

      helper Decidim::DatetimeHelper

      before_action :authenticate_user!

      helper_method :username_list, :chat

      def new
        authorize! :create, Chat

        @form = form(ChatForm).from_params(params)
      end

      def create
        authorize! :create, Chat

        @form = form(ChatForm).from_params(params)

        StartChat.call(@form) do
          on(:ok) do |chat|
            render action: :create, locals: {
              chat: chat,
              form: MessageForm.new
            }
          end

          on(:invalid) do
            render json: { error: I18n.t("messaging.chats.create.error", scope: "decidim") }, status: 422
          end
        end
      end

      def index
        authorize! :index, Chat

        @chats = UserChats.for(current_user)
      end

      def show
        authorize! :show, chat

        @form = MessageForm.new
      end

      def update
        authorize! :update, chat

        @form = form(MessageForm).from_params(params)

        ReplyToChat.call(chat, @form) do
          on(:ok) do |message|
            render action: :update, locals: { message: message }
          end

          on(:invalid) do
            render json: { error: I18n.t("messaging.chats.update.error", scope: "decidim") }, status: 422
          end
        end
      end

      private

      def chat
        @chat ||= Chat.find(params[:id])
      end

      def username_list(users)
        users.pluck(:name).join(", ")
      end
    end
  end
end
