# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      class QuestionnairePermissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin
          return permission_action unless subject == :questionnaire

          case permission_action.action
          when :update
            toggle_allow(registration_form.present?)
          when :export_responses
            allow!
          end

          permission_action
        end

        private

        def registration_form
          @registration_form ||= context.fetch(:questionnaire, nil)
        end
      end
    end
  end
end
