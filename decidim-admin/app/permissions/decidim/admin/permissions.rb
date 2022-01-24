# frozen_string_literal: true

module Decidim
  module Admin
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action if managed_user_action?

        unless permission_action.scope == :admin
          read_admin_dashboard_action?
          return permission_action
        end

        unless user
          disallow!
          return permission_action
        end

        if user_manager?
          begin
            allow! if user_manager_permissions.allowed?
          rescue Decidim::PermissionAction::PermissionNotSetError
            nil
          end
        end

        allow! if user_can_enter_space_area?(require_admin_terms_accepted: true)

        read_admin_dashboard_action?
        apply_newsletter_permissions_for_admin!

        allow! if permission_action.subject == :global_moderation

        if user.admin? && admin_terms_accepted?
          allow! if read_admin_log_action?
          allow! if read_metrics_action?
          allow! if static_page_action?
          allow! if organization_action?
          allow! if user_action?

          allow! if permission_action.subject == :category
          allow! if permission_action.subject == :component
          allow! if permission_action.subject == :admin_user
          allow! if permission_action.subject == :attachment
          allow! if permission_action.subject == :editor_image
          allow! if permission_action.subject == :attachment_collection
          allow! if permission_action.subject == :scope
          allow! if permission_action.subject == :scope_type
          allow! if permission_action.subject == :area
          allow! if permission_action.subject == :area_type
          allow! if permission_action.subject == :user_group
          allow! if permission_action.subject == :officialization
          allow! if permission_action.subject == :moderate_users
          allow! if permission_action.subject == :authorization
          allow! if permission_action.subject == :authorization_workflow
          allow! if permission_action.subject == :static_page_topic
          allow! if permission_action.subject == :help_sections
          allow! if permission_action.subject == :share_token
          allow! if permission_action.subject == :reminder
        end

        permission_action
      end

      private

      def user_manager?
        user && !user.admin? && user.role?("user_manager")
      end

      def read_admin_dashboard_action?
        return unless permission_action.subject == :admin_dashboard &&
                      permission_action.action == :read

        return user_manager_permissions if user_manager?

        toggle_allow(user.admin? || space_allows_admin_access_to_current_action?)
      end

      def apply_newsletter_permissions_for_admin!
        return unless admin_terms_accepted?
        return unless permission_action.subject == :newsletter
        return allow! if user.admin?
        return unless space_allows_admin_access?

        newsletter = context.fetch(:newsletter, nil)

        case permission_action.action
        when :index, :create
          allow!
        when :read, :update, :destroy
          toggle_allow(user == newsletter.author)
        end
      end

      def space_allows_admin_access?
        Decidim.participatory_space_manifests.any? do |manifest|
          Decidim.find_participatory_space_manifest(manifest.name)
                 .participatory_spaces.call(organization)&.any? do |space|
            space.admins.exists?(id: user.id)
          end
        end
      end

      def read_metrics_action?
        permission_action.subject == :metrics &&
          permission_action.action == :read
      end

      def read_admin_log_action?
        permission_action.subject == :admin_log &&
          permission_action.action == :read
      end

      def static_page_action?
        return unless permission_action.subject == :static_page

        static_page = context.fetch(:static_page, nil)

        case permission_action.action
        when :update
          static_page.present?
        when :update_slug, :destroy
          static_page.present? && !StaticPage.default?(static_page.slug)
        when :update_notable_changes
          static_page.slug == "terms-and-conditions" && static_page.persisted?
        else
          true
        end
      end

      def organization_action?
        return unless permission_action.subject == :organization
        return unless permission_action.action == :update

        organization == user.organization
      end

      def managed_user_action?
        return unless permission_action.subject == :managed_user
        return user_manager_permissions if user_manager?
        return unless user&.admin?

        case permission_action.action
        when :create
          toggle_allow(!organization.available_authorizations.empty?)
        else
          allow!
        end

        true
      end

      def user_action?
        return unless [:user, :impersonatable_user].include?(permission_action.subject)

        subject_user = context.fetch(:user, nil)

        case permission_action.action
        when :promote
          subject_user.managed? && Decidim::ImpersonationLog.active.where(admin: user).empty?
        when :impersonate
          available_authorization_handlers? &&
            !subject_user.admin? &&
            subject_user.roles.empty? &&
            Decidim::ImpersonationLog.active.where(admin: user).empty?
        when :destroy
          subject_user != user
        else
          true
        end
      end

      def organization
        @organization ||= context.fetch(:organization, nil) || context.fetch(:current_organization, nil)
      end

      def user_can_enter_space_area?(**args)
        return unless permission_action.action == :enter &&
                      permission_action.subject == :space_area

        space_allows_admin_access_to_current_action?(**args)
      end

      def space_allows_admin_access_to_current_action?(require_admin_terms_accepted: false)
        Decidim.participatory_space_manifests.any? do |manifest|
          next if manifest.name != :initiatives && require_admin_terms_accepted && !admin_terms_accepted?

          new_permission_action = Decidim::PermissionAction.new(
            action: permission_action.action,
            scope: permission_action.scope,
            subject: permission_action.subject
          )
          manifest.permissions_class.new(user, new_permission_action, context).permissions.allowed?
        rescue Decidim::PermissionAction::PermissionNotSetError
          nil
        end
      end

      def user_manager_permissions
        Decidim::Admin::UserManagerPermissions.new(user, permission_action, context).permissions
      end

      def admin_terms_accepted?
        return unless permission_action.scope == :admin

        user&.admin_terms_accepted?
      end

      def available_authorization_handlers?
        user.organization.available_authorization_handlers.any?
      end
    end
  end
end
