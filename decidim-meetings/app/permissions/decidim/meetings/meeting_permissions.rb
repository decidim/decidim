# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingPermissions < Decidim::DefaultPermissions
      def permissions
        return permission_action if permission_action.scope != :public

        return permission_action unless subject == :meeting

        if permission_action.action == :read
          toggle_allow(user_has_any_role?(user, meeting.participatory_space, broad_check: true) || (!meeting&.hidden? && meeting&.current_user_can_visit_meeting?(user)))
          return permission_action
        end

        return permission_action unless user

        toggle_allow(can_join_meeting?) if action == :join
        toggle_allow(can_join_waitlist?) if action == :join_waitlist
        toggle_allow(can_leave_meeting?) if action == :leave
        toggle_allow(can_decline_invitation?) if action == :decline_invitation
        toggle_allow(can_create_meetings?) if action == :create
        toggle_allow(can_update_meeting?) if action == :update
        toggle_allow(can_withdraw_meeting?) if action == :withdraw
        toggle_allow(can_close_meeting?) if action == :close
        toggle_allow(can_register_invitation_meeting?) if action == :register
        toggle_allow(can_reply_poll?) if action == :reply_poll

        permission_action
      end

      private

      def meeting
        @meeting ||= context.fetch(:meeting, nil)
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
    end
  end
end
