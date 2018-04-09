# frozen_string_literal: true

module Decidim
  module Admin
    class Permissions
      def initialize(user, permission_action, context = {})
        @user = user
        @permission_action = permission_action
        @context = context
      end

      def permissions
        unless permission_action.scope == :admin
          permission_action.disallow!
          return permission_action
        end

        unless user
          permission_action.disallow!
          return permission_action
        end

        return Decidim::Admin::UserManagerPermissions.new(user, permission_action, context).permissions if user_manager?

        permission_action.allow! if user_can_enter_space_area?

        permission_action.allow! if read_admin_dashboard_action?

        unless user.admin?
          permission_action.disallow!
          return permission_action
        end

        permission_action.allow! if read_admin_log_action?
        permission_action.allow! if static_page_action?
        permission_action.allow! if organization_action?
        permission_action.allow! if managed_user_action?
        permission_action.allow! if user_action?

        permission_action.allow! if permission_action.subject == :category
        permission_action.allow! if permission_action.subject == :component
        permission_action.allow! if permission_action.subject == :admin_user
        permission_action.allow! if permission_action.subject == :attachment
        permission_action.allow! if permission_action.subject == :attachment_collection
        permission_action.allow! if permission_action.subject == :scope
        permission_action.allow! if permission_action.subject == :scope_type
        permission_action.allow! if permission_action.subject == :area
        permission_action.allow! if permission_action.subject == :area_type
        permission_action.allow! if permission_action.subject == :newsletter
        permission_action.allow! if permission_action.subject == :oauth_application
        permission_action.allow! if permission_action.subject == :user_group
        permission_action.allow! if permission_action.subject == :officialization
        permission_action.allow! if permission_action.subject == :authorization
        permission_action.allow! if permission_action.subject == :authorization_workflow

        permission_action
      end

      private

      attr_reader :user, :context, :permission_action

      def read_admin_dashboard_action?
        return unless permission_action.subject == :admin_dashboard &&
                      permission_action.action == :read

        user.admin? ? true : space_allows_admin_access_to_current_action?
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

        case permission_action.action
        when :create
          !organization.available_authorizations.empty?
        else
          true
        end
      end

      def user_action?
        return unless permission_action.subject == :user
        subject_user = context.fetch(:user, nil)

        case permission_action.action
        when :impersonate, :promote
          subject_user.managed? && Decidim::ImpersonationLog.active.empty?
        when :destroy
          subject_user != user
        else
          true
        end
      end

      def organization
        @organization ||= context.fetch(:organization, nil) || context.fetch(:current_organization, nil)
      end

      def user_manager?
        !@user.admin? && @user.role?("user_manager")
      end

      def user_can_enter_space_area?
        return unless permission_action.action == :enter &&
                      permission_action.subject == :space_area

        space_allows_admin_access_to_current_action?
      end

      def space_allows_admin_access_to_current_action?
        Decidim.participatory_space_manifests.any? do |manifest|
          next if manifest.name == :consultations
          begin
            manifest.permissions_class.new(user, permission_action, context).permissions.allowed?
          rescue Decidim::PermissionnAction::PermissionNotSetError
            nil
          end
        end
      end
    end
  end
end
