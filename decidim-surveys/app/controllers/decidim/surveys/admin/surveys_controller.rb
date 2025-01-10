# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This controller allows the user to update a Page.
      class SurveysController < Admin::ApplicationController
        include Decidim::Forms::Admin::Concerns::HasQuestionnaire
        include Decidim::Forms::Admin::Concerns::HasQuestionnaireAnswersUrlHelper
        include Decidim::Surveys::Admin::Filterable

        helper_method :surveys

        def index; end

        def create
          enforce_permission_to(:create, :questionnaire)
          Decidim::Surveys::CreateSurvey.call(current_component) do
            on(:ok) do |survey|
              flash[:notice] = I18n.t("create.success", scope: "decidim.surveys.admin.surveys")
              redirect_to edit_survey_path(survey)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("create.invalid", scope: "decidim.surveys.admin.surveys")
              render action: "index"
            end
          end
        end

        def edit
          enforce_permission_to(:update, :questionnaire, questionnaire:)
          @form = form(Admin::SurveyForm).from_model(survey)
        end

        def update
          enforce_permission_to(:update, :questionnaire, questionnaire:)
          @form = form(Admin::SurveyForm).from_params(params)

          Admin::UpdateSurvey.call(@form, survey, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("update.success", scope: "decidim.surveys.admin.surveys")
              redirect_to(surveys_path) && return
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("update.invalid", scope: "decidim.surveys.admin.surveys")
              render action: "edit"
            end
          end
        end

        def publish
          enforce_permission_to(:update, :questionnaire, questionnaire:)
          Decidim::Surveys::Admin::PublishSurvey.call(survey, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("publish.success", scope: "decidim.surveys.admin.surveys")
              redirect_to surveys_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("publish.invalid", scope: "decidim.surveys.admin.surveys")
              render action: "index"
            end
          end
        end

        def unpublish
          enforce_permission_to(:update, :questionnaire, questionnaire:)
          Decidim::Surveys::Admin::UnpublishSurvey.call(survey, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("unpublish.success", scope: "decidim.surveys.admin.surveys")
              redirect_to surveys_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("unpublish.invalid", scope: "decidim.surveys.admin.surveys")
              render action: "index"
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :questionnaire, questionnaire:)
          Decidim::Commands::DestroyResource.call(survey, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("destroy.success", scope: "decidim.surveys.admin.surveys")

              redirect_to surveys_path
            end
          end
        end

        def edit_questions_template
          "decidim/surveys/admin/surveys/edit_questions"
        end

        def questionnaire_for
          survey
        end

        def after_update_url
          surveys_path
        end

        def questionnaire_participants_url
          Decidim::EngineRouter.admin_proxy(survey.component).survey_answers_path(survey)
        end

        # Specify the public url from which the survey can be viewed and answered
        def public_url
          Decidim::EngineRouter.main_proxy(current_component).survey_path(survey)
        end

        def edit_questionnaire_title
          t(:title, scope: "decidim.forms.admin.questionnaires.form", questionnaire_for: translated_attribute(current_component.name))
        end

        private

        def surveys
          @surveys ||= filtered_collection
        end

        def survey
          @survey ||= collection.find(params[:id])
        end

        def collection
          @collection ||= Decidim::Surveys::Survey.where(component: current_component)
        end
      end
    end
  end
end
