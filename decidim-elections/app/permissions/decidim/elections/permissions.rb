# frozen_string_literal: true

module Decidim
  module Elections
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Anonymous users can only view elections
        toggle_allow(can_view?) if permission_action.scope == :public && permission_action.subject == :election && permission_action.action == :view

        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Elections::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        return permission_action if permission_action.scope != :public
        return permission_action if permission_action.subject != :election

        case permission_action.action
        when :vote
          toggle_allow(can_vote?)
        when :preview
          toggle_allow(can_preview?)
        end

        permission_action
      end

      private

      def can_view?
        election.published? || user&.admin?
      end

      def can_vote?
        election.published? && election.ongoing? && authorized_to_vote?
      end

      def can_preview?
        user.admin? && !can_vote?
      end

      def authorized_to_vote?
        authorized?(:vote, resource: election)
      end

      def election
        @election ||= context[:election]
      end
    end
  end
end
