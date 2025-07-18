# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingPermissions < Decidim::DefaultPermissions
      def permissions
        return permission_action if permission_action.scope != :public

        return permission_action unless subject == :meeting

        if permission_action.action == :read
          toggle_allow(can_read?)
          return permission_action
        end

        return permission_action unless user

        meeting_actions

        permission_action
      end

      private

      def meeting
        @meeting ||= context.fetch(:meeting, nil)
      end

      def meeting_actions
        action_permissions = {
          join: :can_join_meeting?,
          join_waitlist: :can_join_waitlist?,
          leave: :can_leave_meeting?,
          decline_invitation: :can_decline_invitation?,
          create: :can_create_meetings?,
          update: :can_update_meeting?,
          withdraw: :can_withdraw_meeting?,
          close: :can_close_meeting?,
          register: :can_register_invitation_meeting?,
          reply_poll: :can_reply_poll?
        }

        permission_method = action_permissions[action]
        toggle_allow(send(permission_method)) if permission_method
      end

      def can_read?
        user_has_any_role?(user, meeting.participatory_space, broad_check: true) || (!meeting&.hidden? && meeting&.current_user_can_visit_meeting?(user))
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

      def can_participate?
        context[:current_component].participatory_space.can_participate?(user)
      end

      def initiative_authorship?
        return false unless Decidim.module_installed?("initiatives")

        participatory_space = context[:current_component].participatory_space

        participatory_space.is_a?(Decidim::Initiative) &&
          participatory_space.has_authorship?(user)
      end
    end
  end
end
