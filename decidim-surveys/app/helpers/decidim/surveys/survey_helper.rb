# frozen_string_literal: true

module Decidim
  module Surveys
    module SurveyHelper
      def no_permission
        render(
          partial: "decidim/authorization_modals/content"
        )
      end

      def resource
        questionnaire_for
      end

      def current_component
        @current_component ||= Decidim::Component.find(params[:component_id])
      end

      def authorization_action
        @authorization_action ||= params[:authorization_action]
      end

      def authorize_action_path(handler_name)
        authorizations.status_for(handler_name).current_path
      end

      def authorizations
        @authorizations ||= action_authorized_to(:answer, resource: questionnaire_for)
      end
    end
  end
end
