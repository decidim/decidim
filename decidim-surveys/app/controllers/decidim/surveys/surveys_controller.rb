# frozen_string_literal: true

module Decidim
  module Surveys
    # Exposes the survey resource so users can view and answer them.
    class SurveysController < Decidim::Surveys::ApplicationController
      include FormFactory

      helper_method :survey

      def show
        @form = form(SurveyForm).from_model(survey)
      end

      def answer
        authorize! :answer, Survey
        @form = form(SurveyForm).from_params(params)

        AnswerSurvey.call(@form, current_user, survey) do
          on(:ok) do
            flash[:notice] = I18n.t("surveys.answer.success", scope: "decidim.surveys")
            redirect_to survey_path(survey)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("surveys.answer.invalid", scope: "decidim.surveys")
            render action: "show"
          end
        end
      end

      private

      def survey
        @survey ||= Survey.find_by(feature: current_feature)
      end
    end
  end
end
