# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      module Settings
        # This controller allows the user to update the settings for a Survey.
        class SurveysController < Admin::ApplicationController
          def edit
            enforce_permission_to(:update, :questionnaire)

            @form = form(Admin::SurveySettingsForm).from_model(survey)
          end

          def update
            enforce_permission_to(:update, :questionnaire)

            @form = form(Admin::SurveySettingsForm).from_params(params)

            Admin::UpdateSurveySettings.call(@form, survey, current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("update.success", scope: "decidim.surveys.admin.surveys")
                redirect_to edit_settings_survey_path(survey)
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("update.invalid", scope: "decidim.surveys.admin.surveys")
                render action: "edit"
              end
            end
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
