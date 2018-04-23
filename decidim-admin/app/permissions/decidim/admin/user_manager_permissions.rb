# frozen_string_literal: true

module Decidim
  module Admin
    class UserManagerPermissions
      def initialize(user, permission_action, context = {})
        @user = user
        @permission_action = permission_action
        @context = context
      end

      def permissions
        permission_action.allow! if read_admin_dashboard_action?

        permission_action.allow! if managed_user_action?
        permission_action.allow! if user_action?

        permission_action
      end

      private

      attr_reader :user, :context, :permission_action

      def read_admin_dashboard_action?
        permission_action.subject == :admin_dashboard &&
          permission_action.action == :read
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
    end
  end
end
