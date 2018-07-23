# frozen_string_literal: true

module Decidim
  module Surveys
    # Exposes the survey resource so users can view and answer them.
    class SurveysController < Decidim::Surveys::ApplicationController
      include FormFactory

      helper_method :survey

      def show
        @form = form(Decidim::Forms::QuestionnaireForm).from_model(survey) # FIXME: remove namespace
      end

      def answer
        enforce_permission_to :answer, :survey

        @form = form(Decidim::Forms::QuestionnaireForm).from_params(params) # FIXME: remove namespace

        Decidim::Forms::AnswerQuestionnaire.call(@form, current_user, survey) do
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
        # @survey ||= Survey.includes(questions: :answer_options).find_by(component: current_component)
        @survey ||= Survey.find_by(component: current_component) # FIXME: restore includes
      end
    end
  end
end
