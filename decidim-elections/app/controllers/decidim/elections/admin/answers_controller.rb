# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows the create or update answers for a question.
      class AnswersController < Admin::ApplicationController
        include Decidim::Proposals::Admin::Picker
        helper Decidim::ApplicationHelper
        helper_method :election, :question, :answers, :answers

        def new
          enforce_permission_to :update, :answer, election: election, question: question
          @form = form(AnswerForm).instance
        end

        def create
          enforce_permission_to :update, :answer, election: election, question: question
          @form = form(AnswerForm).from_params(params, election: election, question: question)

          CreateAnswer.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("answers.create.success", scope: "decidim.elections.admin")
              redirect_to election_question_answers_path(election, question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("answers.create.invalid", scope: "decidim.elections.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :answer, election: election, question: question
          @form = form(AnswerForm).from_model(answer)
        end

        def update
          enforce_permission_to :update, :answer, election: election, question: question
          @form = form(AnswerForm).from_params(params, election: election, question: question)

          UpdateAnswer.call(@form, answer) do
            on(:ok) do
              flash[:notice] = I18n.t("answers.update.success", scope: "decidim.elections.admin")
              redirect_to election_question_answers_path(election, question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("answers.update.invalid", scope: "decidim.elections.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :update, :answer, election: election, question: question

          DestroyAnswer.call(answer, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("answers.destroy.success", scope: "decidim.elections.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("answers.destroy.invalid", scope: "decidim.elections.admin")
            end
          end

          redirect_to election_question_answers_path(election, question)
        end

        private

        def election
          @election ||= Election.where(component: current_component).find_by(id: params[:election_id])
        end

        def question
          @question ||= election.questions.find_by(id: params[:question_id])
        end

        def answers
          @answers ||= question.answers
        end

        def answer
          answers.find(params[:id])
        end
      end
    end
  end
end
