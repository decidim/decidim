# frozen_string_literal: true

module Decidim
  module Elections
    class Permissions < Decidim::DefaultPermissions
      def permissions
        check_view_election_permissions

        toggle_allow(can_answer_feedback?) if permission_action.scope == :public && permission_action.subject == :questionnaire && permission_action.action == :answer

        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Elections::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        # Delegate the trustee_zone permission checks to the trustee zone permissions class
        return Decidim::Elections::TrusteeZone::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :trustee_zone

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

      def check_view_election_permissions
        return unless permission_action.scope == :public &&
                      permission_action.action == :view &&
                      permission_action.subject == :election

        toggle_allow(can_view?)
      end

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

      def can_answer_feedback?
        return unless user && election

        authorized_to_vote? && !election.questionnaire.answered_by?(user)
      end

      def election
        @election ||= context[:election]
      end
    end
  end
end
