# frozen_string_literal: true

module Decidim
  module Meetings
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Meetings::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :meeting

        case permission_action.action
        when :join
          toggle_allow(can_join_meeting?)
        when :leave
          toggle_allow(can_leave_meeting?)
        when :decline_invitation
          toggle_allow(can_decline_invitation?)
        when :create
          toggle_allow(can_create_meetings?)
        when :update
          toggle_allow(can_update_meeting?)
        end

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

      def can_leave_meeting?
        meeting.registrations_enabled?
      end

      def can_decline_invitation?
        meeting.registrations_enabled? &&
          meeting.invites.where(user: user).exists?
      end

      def can_create_meetings?
        component_settings&.creation_enabled_for_participants?
      end

      def can_update_meeting?
        component_settings&.creation_enabled_for_participants? &&
          meeting.organizer == user
      end
    end
  end
end
