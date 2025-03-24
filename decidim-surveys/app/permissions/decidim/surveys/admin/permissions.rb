# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user

          return permission_action unless permission_action.scope == :admin

          case permission_action.subject
          when :questionnaire
            case permission_action.action
            when :export_responses, :update, :create, :destroy
              permission_action.allow!
            end
          when :questionnaire_responses
            case permission_action.action
            when :index, :show, :export_response
              permission_action.allow!
            end
          when :questionnaire_publish_responses
            case permission_action.action
            when :index, :update, :destroy
              if context.fetch(:survey).allow_responses
                permission_action.disallow!
              else
                permission_action.allow!
              end
            end
          end

          permission_action
        end
      end
    end
  end
end
