# frozen_string_literal: true

module Decidim
  module Elections
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Elections::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :election

        allowed_election_action?

        permission_action
      end

      private

      def election
        @election ||= context.fetch(:election, nil)
      end

      def allowed_election_action?
        return unless permission_action.subject == :election

        case permission_action.action
        when :read
          allow! if election.present? && election.published?
        end
      end
    end
  end
end
