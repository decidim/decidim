# frozen_string_literal: true
module Decidim
  module Surveys
    module Admin
      # This controller allows the user to update a Page.
      class SurveysController < Admin::ApplicationController
        helper_method :survey, :blank_question, :question_types

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
          @survey ||= Survey.find_by(feature: current_feature)
        end

        def blank_question
          @blank_question ||= survey.questions.build(body: {})
        end

        def question_types
          @question_types ||= SurveyQuestion::TYPES.map do |question_type|
            [question_type, I18n.t("decidim.surveys.question_types.#{question_type}")]
          end
        end
      end
    end
  end
end
