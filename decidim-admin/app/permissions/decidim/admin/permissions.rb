# frozen_string_literal: true

module Decidim
  module Admin
    class Permissions
      def initialize(user, permission_action, context = {})
        @user = user
        @permission_action = permission_action
        @context = context
      end

      def allowed?
        return false unless permission_action.scope == :admin

        return false unless user
        return Decidim::Admin::UserManagerPermissions.new(user, permission_action, context).allowed? if user_manager?
        return false unless user.admin?

        return true if read_admin_dashboard_action?

        return true if read_admin_log_action?
        return true if static_page_action?
        return true if organization_action?
        return true if managed_user_action?
        return true if user_action?

        return true if permission_action.subject == :category
        return true if permission_action.subject == :component
        return true if permission_action.subject == :admin_user
        return true if permission_action.subject == :attachment
        return true if permission_action.subject == :attachment_collection
        return true if permission_action.subject == :scope
        return true if permission_action.subject == :scope_type
        return true if permission_action.subject == :area
        return true if permission_action.subject == :area_type
        return true if permission_action.subject == :newsletter
        return true if permission_action.subject == :oauth_application
        return true if permission_action.subject == :user_group
        return true if permission_action.subject == :officialization
        return true if permission_action.subject == :authorization
        return true if permission_action.subject == :authorization_workflow

        false
      end

      private

      attr_reader :user, :context, :permission_action

      def read_admin_dashboard_action?
        permission_action.subject == :admin_dashboard &&
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
        else
          true
        end
      end

      def organization_action?
        return unless permission_action.subject == :organization

        return unless [:read, :update].include?(permission_action.action)
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
    end
  end
end
