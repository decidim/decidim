# frozen_string_literal: true

module Decidim
  module Votings
    class Permissions < Decidim::DefaultPermissions
      def permissions
        allowed_public_anonymous_action?

        return permission_action unless user

        return Decidim::Votings::Admin::Permissions.new(user, permission_action, context).permissions if admin_scope?

        # Delegate the polling_officer_zone permission checks to the polling officer zone permissions class
        return Decidim::Votings::PollingOfficerZone::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :polling_officer_zone

        permission_action
      end

      private

      def voting
        @voting ||= context.fetch(:voting, nil)
      end

      def allowed_public_anonymous_action?
        return unless permission_action.action == :read
        return unless permission_action.scope == :public

        case permission_action.subject
        when :votings, :participatory_space
          allow!
        when :voting
          toggle_allow(voting.published? || user&.admin?)
        end
      end

      def admin_scope?
        permission_action.scope == :admin || permission_action.subject == :admin_dashboard
      end
    end
  end
end
