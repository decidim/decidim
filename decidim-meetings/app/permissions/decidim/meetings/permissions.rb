# frozen_string_literal: true

module Decidim
  module Meetings
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Meetings::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        if permission_action.subject == :meeting && permission_action.action == :read
          toggle_allow(user_has_any_role?(user, meeting.participatory_space, broad_check: true) || (!meeting&.hidden? && meeting&.current_user_can_visit_meeting?(user)))
          return permission_action
        end

        return permission_action unless user

        return permission_action if permission_action.subject

        allow! if subject == :response && action == :create && can_respond_question?
        allow! if subject == :question && action == :update && can_update_question?
        allow! if subject == :meeting && action == :join && can_join_meeting?
        allow! if subject == :meeting && action == :leave && can_leave_meeting?
        allow! if subject == :meeting && action == :decline_invitation && can_decline_invitation?
        allow! if subject == :meeting && action == :create && can_create_meetings?
        allow! if subject == :meeting && action == :update && can_update_meeting?
        allow! if subject == :meeting && action == :withdraw && can_withdraw_meeting?
        allow! if subject == :meeting && action == :close && can_close_meeting?
        allow! if subject == :meeting && action == :register && can_register_invitation_meeting?
        allow! if subject == :meeting && action == :reply_poll && can_reply_poll?
        allow! if subject == :poll && action == :update && can_update_poll?

        permission_action
      end

      private

      def meeting
        @meeting ||= context.fetch(:meeting, nil)
      end

      def question
        @question ||= context.fetch(:question, nil)
      end

      def can_join_meeting?
        meeting.can_be_joined_by?(user) &&
          authorized?(:join, resource: meeting)
      end

      def can_join_waitlist?
        meeting.waitlist_enabled? &&
          !meeting.has_available_slots? &&
          !meeting.has_registration_for?(user) &&
          authorized?(:join_waitlist, resource: meeting)
      end

      def can_leave_meeting?
        meeting.registrations_enabled?
      end

      def can_decline_invitation?
        meeting.registrations_enabled? &&
          meeting.invites.exists?(user:)
      end

      def can_create_meetings?
        (component_settings&.creation_enabled_for_participants? && can_participate?) || initiative_authorship?
      end

      def can_participate?
        context[:current_component].participatory_space.can_participate?(user)
      end

      def initiative_authorship?
        return false unless Decidim.module_installed?("initiatives")

        participatory_space = context[:current_component].participatory_space

        participatory_space.is_a?(Decidim::Initiative) &&
          participatory_space.has_authorship?(user)
      end

      # Neither platform admins, nor space admins should be able to create meetings from the public side.
      def space_member?(participatory_space, user)
        return false unless user

        participatory_space.participatory_space_private_users.exists?(decidim_user_id: user.id)
      end

      def can_update_meeting?
        meeting.authored_by?(user) &&
          !meeting.closed?
      end

      def can_withdraw_meeting?
        meeting.authored_by?(user) &&
          !meeting.withdrawn? &&
          !meeting.past?
      end

      def can_close_meeting?
        meeting.authored_by?(user) &&
          meeting.past?
      end

      def can_register_invitation_meeting?
        meeting.can_register_invitation?(user) &&
          authorized?(:register, resource: meeting)
      end

      def can_reply_poll?
        meeting.present? &&
          meeting.poll.present? &&
          authorized?(:reply_poll, resource: meeting)
      end

      def can_update_poll?
        user.present? &&
          user.admin? &&
          meeting.present? &&
          meeting.poll.present?
      end

      def can_respond_question?
        question.present? && user.present? && !question.responded_by?(user)
      end

      def can_update_question?
        user.present? && user.admin? && question.present?
      end
    end
  end
end
