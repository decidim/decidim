# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This controller allows the user to update a Page.
      class SurveysController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaire
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireAnswers
        include Decidim::Surveys::Admin::Filterable

        helper_method :surveys

        def index; end

        def new
          @form = form(Decidim::Forms::Admin::QuestionnaireForm).instance
        end

        def create
          Decidim::Surveys::CreateSurvey.call(@current_component) do
            on(:ok) do
              flash[:notice] = I18n.t("surveys.create.success", scope: "decidim.surveys.admin")
              redirect_to surveys_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("surveys.create.invalid", scope: "decidim.surveys.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to(:update, :questionnaire, questionnaire:)

          @form = form(Decidim::Forms::Admin::QuestionnaireForm).from_model(survey.questionnaire)
        end

        def questionnaire_for
          survey.questionnaire
        end

        # Specify the public url from which the survey can be viewed and answered
        def public_url
          Decidim::EngineRouter.main_proxy(current_component).survey_path(survey)
        end

        # Specify where to redirect after exporting a user response
        def questionnaire_participant_answers_url(session_token)
          Decidim::EngineRouter.admin_proxy(survey.component).show_survey_path(session_token:)
        end

        def edit_questionnaire_title
          t(:title, scope: "decidim.forms.admin.questionnaires.form", questionnaire_for: translated_attribute(current_component.name))
        end

        private

        def i18n_flashes_scope
          "decidim.surveys.admin.surveys"
        end

        def surveys
          @surveys ||= filtered_collection
        end

        def survey
          @survey ||= collection.find(params[:id])
        end

        def collection
          @collection ||= Survey.where(component: current_component)
        end
      end
    end
  end
end
