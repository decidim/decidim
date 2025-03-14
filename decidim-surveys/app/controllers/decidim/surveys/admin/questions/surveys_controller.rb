# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      module Questions
        # This controller allows the user create and edit questionnaires for Surveys.
        class SurveysController < Admin::ApplicationController
          include Decidim::Forms::Admin::Concerns::HasQuestionnaire
          include Decidim::Forms::Admin::Concerns::HasQuestionnaireResponsesUrlHelper

          helper_method :surveys

          def edit_questions_template
            "decidim/surveys/admin/questions/surveys/edit"
          end

          def questionnaire_for
            survey
          end

          def after_update_url
            edit_questions_questions_survey_path(survey)
          end

          def questionnaire_participants_url
            Decidim::EngineRouter.admin_proxy(survey.component).survey_responses_path(survey)
          end

          # Specify the public url from which the survey can be viewed and responded
          def public_url
            Decidim::EngineRouter.main_proxy(current_component).survey_path(survey)
          end

          def edit_questionnaire_title
            t(:title, scope: "decidim.forms.admin.questionnaires.form", questionnaire_for: translated_attribute(current_component.name))
          end

          private

          def survey
            @survey ||= Decidim::Surveys::Survey.where(component: current_component).find(params[:id])
          end
        end
      end
    end
  end
end
