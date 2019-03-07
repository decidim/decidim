# frozen_string_literal: true

module Decidim
  module Surveys
    # Exposes the survey resource so users can view and answer them.
    class SurveysController < Decidim::Surveys::ApplicationController
      include Decidim::Forms::Concerns::HasQuestionnaire
      helper Decidim::Surveys::SurveyHelper

      delegate :allow_answers?, to: :current_settings

      before_action :check_permissions

      def check_permissions
        render :no_permission unless action_authorized_to(:answer, resource: survey).ok?
      end

      def questionnaire_for
        survey
      end

      private

      def i18n_flashes_scope
        "decidim.surveys.surveys"
      end

      def survey
        @survey ||= Survey.find_by(component: current_component)
      end
    end
  end
end
