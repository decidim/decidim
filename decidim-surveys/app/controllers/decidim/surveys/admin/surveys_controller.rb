# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This controller allows the user to update a Page.
      class SurveysController < Admin::ApplicationController
        helper_method :survey, :blank_question, :blank_answer_option, :question_types

        def edit
          enforce_permission_to :update, :survey, survey: survey

          @form = form(Decidim::Forms::Admin::QuestionnaireForm).from_model(survey) # FIXME: remove namespace
        end

        def update
          enforce_permission_to :update, :survey, survey: survey

          params["published_at"] = Time.current if params.has_key? "save_and_publish"
          @form = form(Decidim::Forms::Admin::QuestionnaireForm).from_params(params) # FIXME: remove namespace

          Decidim::Forms::Admin::UpdateQuestionnaire.call(@form, survey) do
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
          @survey ||= Survey.find_by(component: current_component)
        end

        def blank_question
          @blank_question ||= Decidim::Forms::Admin::QuestionForm.new # FIXME: remove namespace
        end

        def blank_answer_option
          @blank_answer_option ||= Decidim::Forms::Admin::AnswerOptionForm.new # FIXME: remove namespace
        end

        def question_types
          @question_types ||= Decidim::Forms::Question::TYPES.map do |question_type| # FIXME: remove namespace
            [question_type, I18n.t("decidim.surveys.question_types.#{question_type}")]
          end
        end
      end
    end
  end
end
