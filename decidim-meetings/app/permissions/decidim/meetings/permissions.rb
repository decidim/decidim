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
        end

        permission_action
      end

      private

      def meeting
        @meeting ||= context.fetch(:meeting, nil)
      end

      def can_join_meeting?
        meeting.can_be_joined_by?(user) &&
          authorized?(:join)
      end

      def can_leave_meeting?
        meeting.registrations_enabled?
      end
    end
  end
end
