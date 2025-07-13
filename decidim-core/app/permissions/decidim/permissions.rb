# frozen_string_literal: true

module Decidim
  class Permissions < DefaultPermissions
    def permissions
      return permission_action unless permission_action.scope == :public

      read_public_pages_action?
      locales_action?
      component_public_action?
      search_scope_action?

      public_report_content_action?

      return permission_action unless user

      user_manager_permissions
      manage_self_user_action?
      authorization_action?
      follow_action?
      amend_action?
      notification_action?
      conversation_action?
      apply_like_permissions if permission_action.subject == :like
      show_my_location_button?

      permission_action
    end

    private

    def public_report_content_action?
      return unless permission_action.action == :create &&
                    permission_action.subject == :moderation

      allow!
    end

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

      return allow! if component.published?
      return allow! if user_can_preview_component?
      return allow! if user_can_admin_component_via_space?

      disallow!
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
      when :update, :destroy
        toggle_allow(authorization.user == user && !authorization.granted?)
      when :renew
        toggle_allow(authorization.user == user && authorization.granted? && authorization.renewable?)
      end
    end

    def follow_action?
      return unless permission_action.subject == :follow
      return allow! if permission_action.action == :create

      follow = context.fetch(:follow, nil)
      toggle_allow(follow&.user == user)
    end

    def amend_action?
      return unless permission_action.subject == :amendment
      return disallow! unless component.settings.amendments_enabled

      case permission_action.action
      when :create
        return allow! if component.current_settings.amendment_creation_enabled
      when :accept,
          :reject
        return allow! if component.current_settings.amendment_reaction_enabled
      when :promote
        return allow! if component.current_settings.amendment_promotion_enabled
      end

      amendment = context.fetch(:amendment, nil)
      toggle_allow(amendment&.amender == user)
    end

    def apply_like_permissions
      is_allowed = current_settings.likes_enabled &&
                   !current_settings.likes_blocked &&
                   authorized?(:like, resource: context.fetch(:resource, nil))

      toggle_allow(is_allowed)
    end

    def notification_action?
      return unless permission_action.subject == :notification
      return allow! if permission_action.action == :read

      notification = context.fetch(:notification, nil)
      toggle_allow(notification&.user == user)
    end

    def conversation_action?
      return unless permission_action.subject == :conversation
      return allow! if permission_action.action == :list

      conversation = context.fetch(:conversation)
      interlocutor = context.fetch(:interlocutor, user)

      return disallow! if [:create, :update].include?(permission_action.action) && !conversation&.accept_user?(interlocutor)

      toggle_allow(conversation&.participating?(interlocutor))
    end

    def user_can_preview_component?
      context[:share_token].present? && Decidim::ShareToken.use!(token_for: component, token: context[:share_token], user:)
    rescue ActiveRecord::RecordNotFound, StandardError
      nil
    end

    def user_can_admin_component?
      new_permission_action = Decidim::PermissionAction.new(
        action: permission_action.action,
        scope: :admin,
        subject: permission_action.subject
      )
      Decidim::Admin::Permissions.new(user, new_permission_action, context).permissions.allowed?
    rescue Decidim::PermissionAction::PermissionNotSetError
      nil
    end

    def user_can_admin_component_via_space?
      Decidim.participatory_space_manifests.any? do |manifest|
        new_permission_action = Decidim::PermissionAction.new(
          action: permission_action.action,
          scope: :admin,
          subject: permission_action.subject
        )
        new_context = context.merge(current_participatory_space: component.participatory_space)
        manifest.permissions_class.new(user, new_permission_action, new_context).permissions.allowed?
      rescue Decidim::PermissionAction::PermissionNotSetError
        nil
      end
    end

    def show_my_location_button?
      return unless permission_action.action == :locate && permission_action.subject == :geolocation

      allow!
    end

    def not_already_active?(authorization)
      Verifications::Authorizations.new(organization: user.organization, user:, name: authorization.name).none?
    end

    def user_manager_permissions
      Decidim::UserManagerPermissions.new(user, permission_action, context).permissions
    end
  end
end
