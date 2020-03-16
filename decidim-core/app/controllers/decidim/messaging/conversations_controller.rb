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

        if @form.recipient.is_a? Enumerable
          participants = @form.recipient.to_a.prepend(current_user)
          conversation = conversation_between_multiple(participants)
        else
          conversation = conversation_between(current_user, @form.recipient)
        end

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
        @form = MessageForm.new
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

      def check_multiple
        @form = form(ConversationForm).from_params(params)
        redirect_link = link_to_current_or_new_conversation_with_multiple(@form.recipient)
        redirect_to redirect_link
      end

      private

      def conversation
        @conversation ||= Conversation.find(params[:id])
      end

      def new_conversation(recipient)
        return nil unless recipient

        if recipient.is_a? Enumerable
          Conversation.new(participants: [current_user] + recipient)
        else
          Conversation.new(participants: [current_user, recipient])
        end
      end

      def username_list(users, shorten = false)
        return users.pluck(:name).join(", ") unless shorten
        return users.pluck(:name).join(", ") unless users.count > 3

        "#{users.first(3).pluck(:name).join(", ")} + #{users.count - 3}"
      end

      def link_to_current_or_new_conversation_with_multiple(users)
        decidim_routes = Decidim::Core::Engine.routes.url_helpers
        return decidim_routes.new_user_session_path unless user_signed_in?

        participants = users.to_a.prepend(current_user)
        conversation = conversation_between_multiple(participants)

        if conversation
          decidim_routes.conversation_path(conversation)
        else
          decidim_routes.new_conversation_path(recipient_id: users.pluck(:id))
        end
      end

      def conversation_between_multiple(participants)
        return if participants.to_set.length <= 1

        UserConversations.for(participants.first).find do |conversation|
          conversation.participants.to_set == participants.to_set
        end
      end
    end
  end
end
