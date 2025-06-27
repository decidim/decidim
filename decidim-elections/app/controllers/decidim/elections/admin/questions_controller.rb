# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionsController < Admin::ApplicationController
        helper_method :election, :update_url, :blank_question, :question_types, :blank_response_option

        helper Decidim::Forms::Admin::ApplicationHelper

        def edit_questions
          enforce_permission_to(:update, :election_question, election:)

          @form = form(Decidim::Elections::Admin::QuestionsForm).from_model(election)

          render template: "decidim/elections/admin/questions/edit_questions"
        end

        def update
          enforce_permission_to(:update, :election_question, election:)

          @form = form(Decidim::Elections::Admin::QuestionsForm).from_params(params, election:)

          Decidim::Elections::Admin::UpdateQuestions.call(@form, election) do
            on(:ok) do
              flash[:notice] = I18n.t("update.success", scope: "decidim.elections.admin.questions")
              redirect_to election_census_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("update.invalid", scope: "decidim.elections.admin.questions")
              render :edit_questions
            end
          end
        end

        private

        def question_types
          @question_types ||= Decidim::Elections::Question::QUESTION_TYPES.map do |question_type|
            [question_type, I18n.t("decidim.forms.question_types.#{question_type}")]
          end
        end

        def election
          @election ||= Decidim::Elections::Election.where(component: current_component).find(params[:id])
        end

        def update_url
          update_questions_election_path(election)
        end

        def blank_question
          @blank_question ||= Decidim::Elections::Admin::QuestionForm.new
        end

        def blank_response_option
          @blank_response_option ||= Decidim::Elections::Admin::ResponseOptionForm.new
        end
      end
    end
  end
end
