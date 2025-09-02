# frozen_string_literal: true

module Decidim
  module Elections
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Elections::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        allowed_election_action?
        allowed_vote_action?

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

      def allowed_vote_action?
        return unless permission_action.subject == :vote

        case permission_action.action
        when :create
          allow! if election.present? && election.published? && election.ongoing?
        end
      end
    end
  end
end
