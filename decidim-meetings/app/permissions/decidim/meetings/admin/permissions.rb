# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          allowed_registration_form_action?
          allowed_meeting_action?
          allowed_agenda_action?
          allowed_poll_action?
          allowed_export_responses?

          permission_action
        end

        private

        def meeting
          @meeting ||= context.fetch(:meeting, nil)
        end

        def agenda
          @agenda ||= context.fetch(:agenda, nil)
        end

        def poll
          @poll ||= context.fetch(:poll, nil)
        end

        def registration_form
          @registration_form ||= context.fetch(:questionnaire, nil)
        end

        def allowed_meeting_action?
          return unless permission_action.subject == :meeting

          return disallow! if meeting && !meeting.official?

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
        end

        def allowed_registration_form_action?
          return unless permission_action.subject == :questionnaire

          case permission_action.action
          when :update
            toggle_allow(registration_form.present?)
          end
        end

        def allowed_agenda_action?
          return unless permission_action.subject == :agenda

          case permission_action.action
          when :create
            toggle_allow(meeting.present?)
          when :update
            toggle_allow(agenda.present? && meeting.present?)
          end
        end

        def allowed_poll_action?
          return unless permission_action.subject == :poll

          case permission_action.action
          when :update
            toggle_allow(poll.present? && meeting.present?)
          end
        end

        def allowed_export_responses?
          return unless permission_action.subject == :questionnaire

          case permission_action.action
          when :export_responses
            permission_action.allow!
          end
        end
      end
    end
  end
end
