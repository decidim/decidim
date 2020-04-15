# frozen_string_literal: true

module Decidim
  module Messaging
    # The controller to handle the user's conversations.
    class ConversationsController < Decidim::ApplicationController
      include ConversationHelper
      include FormFactory

      helper ConversationHelper

      before_action :authenticate_user!

      helper_method :username_list, :conversation

      # Shows the form to initiate a conversation with an user (the recipient)
      # recipient is passed via GET parameter:
      #   - if the recipient does not exists, goes back to the users profile page
      #   - if the user already has a conversation with the user, redirects to the initiated conversation
      def new
        @form = form(ConversationForm).from_params(params)
        conversation = conversation_between(current_user, @form.recipient)

        return redirect_back(fallback_location: profile_path(current_user.nickname)) unless @form.recipient

        return redirect_to conversation_path(conversation) if conversation

        enforce_permission_to :create, :conversation, conversation: new_conversation(@form.recipient)
      end

      def create
        @form = form(ConversationForm).from_params(params)
        enforce_permission_to :create, :conversation, conversation: new_conversation(@form.recipient)

        StartConversation.call(@form) do
          on(:ok) do |conversation|
            render action: :create, locals: {
              conversation: conversation,
              form: MessageForm.new
            }
          end

          on(:invalid) do
            render json: { error: I18n.t("messaging.conversations.create.error", scope: "decidim") }, status: :unprocessable_entity
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

        @form = MessageForm.new
      end

      def update
        enforce_permission_to :update, :conversation, conversation: conversation

        @form = form(MessageForm).from_params(params)

        ReplyToConversation.call(conversation, @form) do
          on(:ok) do |message|
            render action: :update, locals: { message: message }
          end

          on(:invalid) do
            render json: { error: I18n.t("messaging.conversations.update.error", scope: "decidim") }, status: :unprocessable_entity
          end
        end
      end

      private

      def conversation
        @conversation ||= Conversation.find(params[:id])
      end

      def new_conversation(recipient)
        return nil unless recipient

        Conversation.new(participants: [current_user, recipient])
      end

      def username_list(users)
        users.pluck(:name).join(", ")
      end
    end
  end
end
