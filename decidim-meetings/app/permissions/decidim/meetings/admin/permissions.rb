# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def allowed?
          # Stop checks if the user is not authorized to perform the
          # permission_action for this space
          return false unless spaces_allows_user?
          return false unless user

          return false if permission_action.scope != :admin

          return false if permission_action.subject != :meeting

          return true if case permission_action.action
                         when :close, :copy, :destroy, :export_registrations, :update
                           meeting.present?
                         when :invite_user
                           meeting.present? && meeting.registrations_enabled?
                         when :create
                           true
                         else
                           false
                         end

          false
        end

        private

        def meeting
          @meeting ||= context.fetch(:meeting, nil)
        end
      end
    end
  end
end
