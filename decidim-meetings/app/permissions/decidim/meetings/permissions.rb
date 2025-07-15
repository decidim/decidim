# frozen_string_literal: true

require_relative "meeting_permissions"

module Decidim
  module Meetings
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Meetings::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return Decidim::Meetings::MeetingPermissions.new(user, permission_action, context).permissions if subject == :meeting

        return permission_action unless user

        toggle_allow(can_respond_question?) if subject == :response && action == :create

        toggle_allow(can_update_question?) if subject == :question && action == :update

        toggle_allow(can_update_poll?) if subject == :poll && action == :update

        permission_action
      end

      private

      def meeting
        @meeting ||= context.fetch(:meeting, nil)
      end

      def question
        @question ||= context.fetch(:question, nil)
      end

      # Neither platform admins, nor space admins should be able to create meetings from the public side.
      def space_member?(participatory_space, user)
        return false unless user

        participatory_space.participatory_space_private_users.exists?(decidim_user_id: user.id)
      end
    end
  end
end
