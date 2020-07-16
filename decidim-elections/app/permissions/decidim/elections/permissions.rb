# frozen_string_literal: true

module Decidim
  module Elections
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Elections::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        return permission_action if permission_action.scope != :public
        return permission_action if permission_action.subject != :election

        case permission_action.action
        when :vote
          allow_if_ongoing
        end

        permission_action
      end

      private

      def allow_if_ongoing
        toggle_allow(can_vote? && election.ongoing?)
      end

      def can_vote?
        authorized?(:vote, resource: election)
      end

      def election
        @election ||= context[:election]
      end
    end
  end
end
