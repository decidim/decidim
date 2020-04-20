# frozen_string_literal: true

module Decidim
  # The controller to show all the conversations for a user or group
  # This controller places conversations in the public profile page.
  # Only for groups at the moment but it will make conversations_controller
  # obsolete in the future
  class UserConversationsController < Decidim::ApplicationController
    include Paginable
    include UserGroups
    include FormFactory
    include Messaging::ConversationHelper

    before_action :authenticate_user!
    before_action :ensure_profile_manager

    helper Decidim::ResourceHelper
    helper_method :user, :conversations, :conversation

    def index
      enforce_permission_to :list, :conversation, interlocutor: user
    end

    def show
      enforce_permission_to :show, :conversation, interlocutor: user, conversation: conversation
    end

    def update
      enforce_permission_to :update, :conversation, interlocutor: user, conversation: conversation

      @form = form(Messaging::MessageForm).from_params(params, sender: user)

      Messaging::ReplyToConversation.call(conversation, @form) do
        on(:ok) do |message|
          render action: :update, locals: { message: message }
        end

        on(:invalid) do
          render action: :update, locals: { error: I18n.t("user_conversations.update.error", scope: "decidim") }, status: :unprocessable_entity
        end
      end
    end

    def new
      @form = form(Messaging::ConversationForm).from_params(params, sender: user)

      return redirect_back(fallback_location: profile_path(user.nickname)) if @form.recipient.empty?

      conversation = conversation_between_multiple([user] + @form.recipient)

      # redirect to existing conversation if already started
      return redirect_to profile_conversation_path(nickname: user.nickname, id: conversation.id) if conversation

      @conversation = Messaging::Conversation.new(participants: [user] + @form.recipient)
      enforce_permission_to :create, :conversation, interlocutor: user, conversation: @conversation

      render :show
    end

    private

    def user
      @user ||= Decidim::UserBaseEntity.find_by(nickname: params[:nickname], organization: current_organization)
    end

    def conversations
      paginate(Messaging::UserConversations.for(user))
    end

    def conversation
      @conversation ||= Messaging::Conversation.find(params[:id])
    end

    def ensure_profile_manager
      return if user.is_a?(UserGroup) && current_user.manageable_user_groups.include?(user)
      return if user == current_user

      raise ActionController::RoutingError, "Conversation not found"
    end
  end
end
