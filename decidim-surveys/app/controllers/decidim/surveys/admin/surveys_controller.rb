# frozen_string_literal: true
module Decidim
  module Surveys
    module Admin
      # This controller allows the user to update a Page.
      class SurveysController < Admin::ApplicationController
        def edit
          authorize! :edit, Survey
          @form = form(Admin::SurveyForm).from_model(survey)
        end

        def update
          authorize! :update, Survey
          params["published_at"] = Time.current if params.has_key? "save_and_publish"
          @form = form(Admin::SurveyForm).from_params(params)

          Admin::UpdateSurvey.call(@form, survey) do
            on(:ok) do
              flash[:notice] = I18n.t("surveys.update.success", scope: "decidim.surveys.admin")
              redirect_to parent_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("surveys.update.invalid", scope: "decidim.surveys.admin")
              render action: "edit"
            end
          end
        end

        private

        def survey
          @survey ||= Surveys::Survey.find_by(feature: current_feature)
        end
      end
    end
  end
end
