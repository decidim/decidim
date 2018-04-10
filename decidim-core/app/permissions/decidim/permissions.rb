# frozen_string_literal: true

module Decidim
  class Permissions < DefaultPermissions
    def permissions
      allow! if read_public_pages_action?
      allow! if locales_action?
      allow! if component_public_action?
      allow! if search_scope_action?

      return permission_action unless user
      return user_manager_permissions if not_admin? && user_manager?

      allow! if manage_self_user_action?
      allow! if authorization_action?
      allow! if follow_action?
      allow! if notification_action?
      allow! if conversation_action?

      permission_action
    end

    private

    def read_public_pages_action?
      permission_action.subject == :public_page &&
        permission_action.action == :read
    end

    def locales_action?
      permission_action.subject == :locales
    end

    def component_public_action?
      permission_action.subject == :component &&
        permission_action.action == :read &&
        component.published?
    end

    def search_scope_action?
      permission_action.subject == :scope &&
        [:search, :pick].include?(permission_action.action)
    end

    def manage_self_user_action?
      permission_action.subject == :user &&
        context.fetch(:current_user, nil) == user
    end

    def authorization_action?
      return unless permission_action.subject == :authorization
      authorization = context.fetch(:authorization, nil)

      case permission_action.action
      when :create
        authorization.user == user && not_already_active?(authorization)
      when :update
        authorization.user == user && !authorization.granted?
      end
    end

    def follow_action?
      return unless permission_action.subject == :follow
      follow = context.fetch(:follow, nil)

      follow.user == user
    end

    def notification_action?
      return unless permission_action.subject == :notification
      notification = context.fetch(:notification, nil)

      notification.user == user
    end

    def conversation_action?
      return unless permission_action.subject == :conversation
      conversation = context.fetch(:conversation, nil)
      return true unless conversation

      conversation.participants.include?(user)
    end

    def not_already_active?(authorization)
      Verifications::Authorizations.new(organization: user.organization, user: user, name: authorization.name).none?
    end

    def user_manager_permissions
      Decidim::UserManagerPermissions.new(user, permission_action, context).permissions
    end

    def not_admin?
      !user.admin?
    end

    # Whether the user has the user_manager role or not.
    def user_manager?
      user.role? "user_manager"
    end
  end
end
