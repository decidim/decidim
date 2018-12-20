# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user

          return permission_action if permission_action.scope != :admin

          return permission_action if permission_action.subject != :questionnaire

          case permission_action.action
          when :export_answers, :update
            permission_action.allow!
          end

          permission_action
        end
      end
    end
  end
end
