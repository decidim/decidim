# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class QuestionsController < Admin::ApplicationController
        helper_method :election, :questions, :question

        def edit_questions
          # enforce_permission_to(:update, :question, election:)
          @questions = election.questions.order(:position)
          @form = if params[:question_id].present?
                    question = election.questions.find_by(id: params[:question_id])
                    form(QuestionForm).from_model(question) if question
                  else
                    form(QuestionForm).instance
                  end
        end

        def update
          # enforce_permission_to(:create, :question, election:)
          @form = form(QuestionForm).from_params(params, election:)

          UpdateQuestion.call(@form) do
            on(:ok) do |question|
              flash[:notice] = I18n.t("questions.update.success", scope: "decidim.elections.admin")
              redirect_to election_question_answers_path(election, question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questions.update.invalid", scope: "decidim.elections.admin")
              render action: "edit_questions"
            end
          end
        end

        private

        def election
          @election ||= Decidim::Elections::Election.where(component: current_component).find(params[:id])
        end

        def questions
          @questions ||= election.questions.order(:position)
        end

        def question
          @question ||= questions.find(params[:id])
        end
      end
    end
  end
end
