# frozen_string_literal: true

module Decidim
  # The controller to show all the conversations for a user or group
  # This controller places conversations in the public profile page.
  # Only for groups at the moment but it will make conversations_controller
  # obsolete in the future
  class UserConversationsController < Decidim::ApplicationController
    include Paginable
    include UserGroups

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
