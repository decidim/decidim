# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class AgendaPermissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin
          return permission_action unless subject == :agenda

          case permission_action.action
          when :create
            toggle_allow(meeting.present?)
          when :update
            toggle_allow(agenda.present? && meeting.present?)
          end

          permission_action
        end

        private

        def agenda
          @agenda ||= context.fetch(:agenda, nil)
        end

        def meeting
          @meeting ||= context.fetch(:meeting, nil)
        end
      end
    end
  end
end
