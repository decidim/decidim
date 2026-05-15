# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class MeetingPermissions < Decidim::DefaultPermissions
        def permissions # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin
          return permission_action unless subject == :meeting

          if meeting && !meeting.official?
            disallow!

            return permission_action
          end

          case permission_action.action
          when :close, :copy, :export_registrations, :update, :read_invites
            toggle_allow(meeting.present?)
          when :invite_attendee
            toggle_allow(meeting.present? && meeting.registrations_enabled?)
          when :validate_registration_code
            toggle_allow(
              meeting.present? &&
              meeting.registrations_enabled? &&
              meeting.component.settings.registration_code_enabled
            )
          when :create
            allow!
          end

          permission_action
        end

        private

        def meeting
          @meeting ||= context.fetch(:meeting, nil)
        end
      end
    end
  end
end
