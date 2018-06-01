# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user

          return permission_action if permission_action.scope != :admin

          if permission_action.subject == :questionnaire
            case permission_action.action
            when :destroy, :update
              toggle_allow(questionnaire.present? && questionnaire.meeting.present?)
            when :create
              allow!
            end
            return permission_action
          end

          return permission_action if permission_action.subject != :meeting

          case permission_action.action
          when :close, :copy, :destroy, :export_registrations, :update
            toggle_allow(meeting.present?)
          when :invite_user
            toggle_allow(meeting.present? && meeting.registrations_enabled?)
          when :create
            allow!
          end

          permission_action
        end

        private

        def meeting
          @meeting ||= context.fetch(:meeting, nil)
        end

        def questionnaire
          @questionnaire ||= context.fetch(:questionnaire, nil)
        end
      end
    end
  end
end
