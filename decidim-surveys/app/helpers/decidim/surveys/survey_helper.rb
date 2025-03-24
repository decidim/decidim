# frozen_string_literal: true

module Decidim
  module Surveys
    module SurveyHelper
      def no_permission
        cell "decidim/authorization_modal", authorizations
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
        @authorizations ||= action_authorized_to(:response, resource: questionnaire_for)
      end

      def filter_date_values
        flat_filter_values(:all, :open, :closed, scope: "decidim.surveys.surveys.filters.date_values")
      end
    end
  end
end
