# frozen_string_literal: true

module Decidim
  module Meetings
    class Permissions < Decidim::DefaultPermissions
      def allowed?
        # Stop checks if the user is not authorized to perform the
        # permission_action for this space
        return false unless spaces_allows_user?
        return false unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Meetings::Admin::Permissions.new(user, permission_action, context).allowed? if permission_action.scope == :admin
        return false if permission_action.scope != :public

        return false if permission_action.subject != :meeting

        return true if case permission_action.action
                       when :join
                         can_join_meeting?
                       when :leave
                         can_leave_meeting?
                       else
                         false
                       end

        false
      end

      private

      def meeting
        @meeting ||= context.fetch(:meeting, nil)
      end

      def can_join_meeting?
        meeting.can_be_joined? &&
          authorized?(:join)
      end

      def can_leave_meeting?
        meeting.registrations_enabled?
      end
    end
  end
end
