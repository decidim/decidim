# frozen_string_literal: true

module Decidim
  module Messaging
    # The controller to handle the user's conversations.
    class ConversationsController < Decidim::ApplicationController
      include ConversationHelper
      include FormFactory

      helper ConversationHelper

      before_action :authenticate_user!

      helper_method :conversation

      def new
        enforce_permission_to :create, :conversation
        @form = form(ConversationForm).from_params(params)

        redirect_back(fallback_location: profile_path(current_user.nickname)) && return unless @form.recipient

        conversation = conversation_between(current_user, @form.recipient)
        redirect_to conversation_path(conversation) if conversation
      end

      def create
        enforce_permission_to :create, :conversation

        @form = form(ConversationForm).from_params(params)

        StartConversation.call(@form) do
          on(:ok) do |conversation|
            redirect_to conversation_path(conversation)
          end

          on(:invalid) do
            render json: { error: I18n.t("messaging.conversations.create.error", scope: "decidim") }, status: 422
          end
        end
      end

      def index
        enforce_permission_to :list, :conversation

        @conversations = UserConversations.for(current_user)
      end

      def show
        enforce_permission_to :read, :conversation, conversation: conversation

        @conversation.mark_as_read(current_user)
      end

      def update
        enforce_permission_to :update, :conversation, conversation: conversation

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
    end
  end
end
