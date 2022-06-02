# frozen_string_literal: true

module Decidim
  module Meetings
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Meetings::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        case permission_action.subject
        when :answer
          case permission_action.action
          when :create
            toggle_allow(can_answer_question?)
          end
        when :question
          case permission_action.action
          when :update
            toggle_allow(can_update_question?)
          end
        when :meeting
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
          when :withdraw
            toggle_allow(can_withdraw_meeting?)
          when :close
            toggle_allow(can_close_meeting?)
          when :register
            toggle_allow(can_register_invitation_meeting?)
          end
        else
          return permission_action
        end

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

      def can_leave_meeting?
        meeting.registrations_enabled?
      end

      def can_decline_invitation?
        meeting.registrations_enabled? &&
          meeting.invites.exists?(user: user)
      end

      def can_create_meetings?
        return false if user.admin?

        component_settings&.creation_enabled_for_participants? && public_space_or_member?
      end

      def public_space_or_member?
        participatory_space = context[:current_component].participatory_space

        participatory_space.private_space? ? space_member?(participatory_space, user) : true
      end

      def space_member?(participatory_space, user)
        return false unless user

        participatory_space.admins.exists?(user.id) || participatory_space.participatory_space_private_users.exists?(decidim_user_id: user.id)
      end

      def can_update_meeting?
        component_settings&.creation_enabled_for_participants? &&
          meeting.authored_by?(user) &&
          !meeting.closed?
      end

      def can_withdraw_meeting?
        component_settings&.creation_enabled_for_participants? &&
          meeting.authored_by?(user) &&
          !meeting.withdrawn? &&
          !meeting.past?
      end

      def can_close_meeting?
        component_settings&.creation_enabled_for_participants? &&
          meeting.authored_by?(user) &&
          meeting.past?
      end

      def can_register_invitation_meeting?
        meeting.can_register_invitation?(user) &&
          authorized?(:register, resource: meeting)
      end

      def can_answer_question?
        question.present? && user.present? && !question.answered_by?(user)
      end

      def can_update_question?
        user.present? && user.admin? && question.present?
      end
    end
  end
end
