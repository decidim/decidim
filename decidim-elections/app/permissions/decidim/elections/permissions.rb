# frozen_string_literal: true

module Decidim
  module Elections
    class Permissions < Decidim::DefaultPermissions
      def permissions
        if permission_action.scope == :public && permission_action.subject == :election
          case permission_action.action
          when :preview
            toggle_allow(can_preview?)
          when :view
            toggle_allow(can_view?)
          when :vote
            toggle_allow(can_vote?)
          when :user_vote
            toggle_allow(can_vote_with_user?)
          end
        end

        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Elections::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        # Delegate the trustee_zone permission checks to the trustee zone permissions class
        return Decidim::Elections::TrusteeZone::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :trustee_zone

        permission_action
      end

      private

      def can_view?
        election.published? || can_preview?
      end

      def can_vote?
        (election.published? && election.ongoing?) || can_preview?
      end

      def can_vote_with_user?
        can_vote? && user && authorized?(:vote, resource: election)
      end

      def can_preview?
        !election.started? && user&.admin?
      end

      def election
        @election ||= context[:election]
      end
    end
  end
end
