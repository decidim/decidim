# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          allowed_meeting_action?
          allowed_agenda_action?
          allowed_minutes_action?

          permission_action
        end

        private

        def meeting
          @meeting ||= context.fetch(:meeting, nil)
        end

        def agenda
          @agenda ||= context.fetch(:agenda, nil)
        end

        def minutes
          @minutes ||= context.fetch(:minutes, nil)
        end

        def allowed_meeting_action?
          return unless permission_action.subject == :meeting

          case permission_action.action
          when :close, :copy, :destroy, :export_registrations, :update
            toggle_allow(meeting.present?)
          when :invite_user
            toggle_allow(meeting.present? && meeting.registrations_enabled?)
          when :create
            allow!
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

        def allowed_minutes_action?
          return unless permission_action.subject == :minutes

          case permission_action.action
          when :create
            toggle_allow(meeting.present?)
          when :update
            toggle_allow(minutes.present? && meeting.present?)
          end
        end
      end
    end
  end
end
