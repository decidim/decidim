# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          return Decidim::Meetings::Admin::MeetingPermissions.new(user, permission_action, context).permissions if subject == :meeting
          return Decidim::Meetings::Admin::QuestionnairePermissions.new(user, permission_action, context).permissions if subject == :questionnaire
          return Decidim::Meetings::Admin::AgendaPermissions.new(user, permission_action, context).permissions if subject == :agenda

          toggle_allow(poll.present? && meeting.present?) if subject == :poll && action == :update

          permission_action
        end

        private

        def meeting
          @meeting ||= context.fetch(:meeting, nil)
        end

        def poll
          @poll ||= context.fetch(:poll, nil)
        end
      end
    end
  end
end
