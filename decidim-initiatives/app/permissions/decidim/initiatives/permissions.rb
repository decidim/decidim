# frozen_string_literal: true

module Decidim
  module Initiatives
    class Permissions < Decidim::DefaultPermissions
      def permissions
        user_can_enter_space_area?

        if read_admin_dashboard_action?
          user_can_read_admin_dashboard?
          return permission_action
        end

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Initiatives::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        # Non-logged users permissions
        read_public_initiative?
        search_initiative_types_and_scopes?

        return permission_action unless user

        create_initiative?
        request_membership?

        vote_initiative?
        unvote_initiative?

        permission_action
      end

      private

      def initiative
        @initiative ||= context.fetch(:initiative, nil)
      end

      def read_public_initiative?
        return unless permission_action.subject == :initiative &&
                      permission_action.action == :read

        allow! if initiative.published? || initiative.rejected? || initiative.accepted?
        allow! if user && (initiative.has_authorship?(user) || user.admin?)
        disallow!
      end

      def search_initiative_types_and_scopes?
        return unless permission_action.action == :search
        return unless [:initiative_type, :initiative_type_scope].include?(permission_action.subject)

        allow!
      end

      def create_initiative?
        return unless permission_action.subject == :initiative &&
                      permission_action.action == :read

        toggle_allow(creation_enabled?)
      end

      def creation_enabled?
        Decidim::Initiatives.creation_enabled && (
          Decidim::Initiatives.do_not_require_authorization ||
            UserAuthorizations.for(user).any? ||
            user.user_groups.verified.any?
        )
      end

      def request_membership?
        return unless permission_action.subject == :initiative &&
                      permission_action.action == :request_membership

        can_request? = !initiative.published? &&
          !initiative.has_authorship?(user) &&
          (
            Decidim::Initiatives.do_not_require_authorization ||
            UserAuthorizations.for(user).any? ||
            user.user_groups.verified.any?
          )

        toggle_allow(can_request?)
      end

      def user_can_enter_space_area?
        return unless user
        return unless permission_action.action == :enter &&
                      permission_action.subject == :space_area &&
                      context.fetch(:space_name, nil) == :initiatives

        toggle_allow(user.admin? || has_initiatives?)
      end

      def has_initiatives?
        (InitiativesCreated.by(user) | InitiativesPromoted.by(user)).any?
      end

      def read_admin_dashboard_action?
        permission_action.action == :read &&
          permission_action.subject == :admin_dashboard
      end

      def user_can_read_admin_dashboard?
        return unless user
        allow! if has_initiatives?
      end

      def vote_initiative?
        return unless permission_action.action == :vote &&
                      permission_action.subject == :initiative

        allow! if initiative.votes_enabled? &&
            initiative.organization&.id == user.organization&.id &&
            initiative.votes.where(decidim_author_id: user.id, decidim_user_group_id: decidim_user_group_id).empty? &&
            (can_user_support?(initiative) || user.user_groups.verified.any?)
      end

      def unvote_initiative?
        return unless permission_action.action == :unvote &&
                      permission_action.subject == :initiative

        allow! if initiative.votes_enabled? &&
          initiative.organization&.id == user.organization&.id &&
          initiative.votes.where(decidim_author_id: user.id, decidim_user_group_id: decidim_user_group_id).any? &&
          (can_user_support?(initiative) || user.user_groups.verified.any?)
      end

      def decidim_user_group_id
        context.fetch(:group_id, nil)
      end

      def can_user_support?(initiative)
        !initiative.offline? && (
          Decidim::Initiatives.do_not_require_authorization ||
          UserAuthorizations.for(user).any?
        )
      end
    end
  end
end
