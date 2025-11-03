# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingPermissions < Decidim::DefaultPermissions
      private

      def target_scope = :public

      def target_subject = :meeting

      def can_read?
        user_has_any_role?(user, meeting.participatory_space, broad_check: true) || (!meeting&.hidden? && meeting&.current_user_can_visit_meeting?(user))
      end

      def meeting
        @meeting ||= context.fetch(:meeting, nil)
      end

      def can_join?
        meeting.can_be_joined_by?(user) &&
          authorized?(:join, resource: meeting)
      end

      def can_join_waitlist?
        meeting.waitlist_enabled? &&
          !meeting.has_available_slots? &&
          !meeting.has_registration_for?(user) &&
          authorized?(:join_waitlist, resource: meeting)
      end

      def can_leave?
        meeting.registrations_enabled?
      end

      def can_decline_invitation?
        meeting.registrations_enabled? &&
          meeting.invites.exists?(user:)
      end

      def can_create?
        return false unless user

        (component_settings&.creation_enabled_for_participants? && can_participate?) || initiative_authorship?
      end

      def can_update?
        meeting.authored_by?(user) &&
          !meeting.closed?
      end

      def can_withdraw?
        meeting.authored_by?(user) &&
          !meeting.withdrawn? &&
          !meeting.past?
      end

      def can_close?
        meeting.authored_by?(user) &&
          meeting.past?
      end

      def can_register?
        return false unless user

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
