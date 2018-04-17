# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user

          return permission_action if permission_action.scope != :admin

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
      end
    end
  end
end
