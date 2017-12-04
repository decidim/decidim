# frozen_string_literal: true

module Decidim
  module Messaging
    # The controller to handle the user's conversations.
    class ConversationsController < Decidim::ApplicationController
      include FormFactory

      helper Decidim::DatetimeHelper

      before_action :authenticate_user!

      helper_method :username_list, :conversation

      def new
        authorize! :create, Conversation

        @form = form(ConversationForm).from_params(params)
      end

      def create
        authorize! :create, Conversation

        @form = form(ConversationForm).from_params(params)

        StartConversation.call(@form) do
          on(:ok) do |conversation|
            render action: :create, locals: {
              conversation: conversation,
              form: MessageForm.new
            }
          end

          on(:invalid) do
            render json: { error: I18n.t("messaging.conversations.create.error", scope: "decidim") }, status: 422
          end
        end
      end

      def index
        authorize! :index, Conversation

        @conversations = UserConversations.for(current_user)
      end

      def show
        authorize! :show, conversation

        @conversation.mark_as_read(current_user)

        @form = MessageForm.new
      end

      def update
        authorize! :update, conversation

        @form = form(MessageForm).from_params(params)

        ReplyToConversation.call(conversation, @form) do
          on(:ok) do |message|
            render action: :update, locals: { message: message }
          end

          on(:invalid) do
            render json: { error: I18n.t("messaging.conversations.update.error", scope: "decidim") }, status: 422
          end
        end
      end

      private

      def conversation
        @conversation ||= Conversation.find(params[:id])
      end

      def username_list(users)
        users.pluck(:name).join(", ")
      end
    end
  end
end
