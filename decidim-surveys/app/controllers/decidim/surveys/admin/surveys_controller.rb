# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This controller allows the user to update a Page.
      class SurveysController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaire
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireAnswers

        def questionnaire_for
          survey
        end

        # Specify where to redirect after exporting a user response
        def questionnaire_participant_answers_url(session_token)
          Decidim::EngineRouter.admin_proxy(survey.component).show_survey_path(session_token: session_token)
        end

        private

        def i18n_flashes_scope
          "decidim.surveys.admin.surveys"
        end

        def survey
          @survey ||= Survey.find_by(component: current_component)
        end
      end
    end
  end
end
