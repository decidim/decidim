# frozen_string_literal: true

module Decidim
  class Permissions < DefaultPermissions
    def permissions
      return permission_action unless permission_action.scope == :public

      read_public_pages_action?
      locales_action?
      component_public_action?
      search_scope_action?

      return permission_action unless user
      return user_manager_permissions if not_admin? && user_manager?

      manage_self_user_action?
      authorization_action?
      follow_action?
      notification_action?
      conversation_action?

      permission_action
    end

    private

    def read_public_pages_action?
      return unless permission_action.subject == :public_page &&
                    permission_action.action == :read
      allow!
    end

    def locales_action?
      return unless permission_action.subject == :locales
      allow!
    end

    def component_public_action?
      return unless permission_action.subject == :component &&
                    permission_action.action == :read

      toggle_allow(component.published?)
    end

    def search_scope_action?
      return unless permission_action.subject == :scope
      toggle_allow([:search, :pick].include?(permission_action.action))
    end

    def manage_self_user_action?
      return unless permission_action.subject == :user
      toggle_allow(context.fetch(:current_user, nil) == user)
    end

    def authorization_action?
      return unless permission_action.subject == :authorization
      authorization = context.fetch(:authorization, nil)

      case permission_action.action
      when :create
        toggle_allow(authorization.user == user && not_already_active?(authorization))
      when :update
        toggle_allow(authorization.user == user && !authorization.granted?)
      end
    end

    def follow_action?
      return unless permission_action.subject == :follow
      return allow! if permission_action.action == :create

      follow = context.fetch(:follow, nil)
      toggle_allow(follow&.user == user)
    end

    def notification_action?
      return unless permission_action.subject == :notification
      return allow! if permission_action.action == :read

      notification = context.fetch(:notification, nil)
      toggle_allow(notification&.user == user)
    end

    def conversation_action?
      return unless permission_action.subject == :conversation
      return allow! if [:create, :list].include?(permission_action.action)

      conversation = context.fetch(:conversation, nil)
      toggle_allow(conversation.participants.include?(user))
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
