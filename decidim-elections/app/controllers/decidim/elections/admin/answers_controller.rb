# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows the create or update answers for a question.
      class AnswersController < Admin::ApplicationController
        include Decidim::Proposals::Admin::Picker
        helper Decidim::ApplicationHelper
        helper_method :election, :question, :answers, :answers, :missing_answers

        def index
          flash.now[:alert] = I18n.t("answers.index.invalid_max_selections", scope: "decidim.elections.admin", missing_answers:) if missing_answers.positive?
        end

        def new
          enforce_permission_to :update, :answer, election: election, question: question
          @form = form(AnswerForm).instance
        end

        def create
          enforce_permission_to :update, :answer, election: election, question: question
          @form = form(AnswerForm).from_params(params, election:, question:)

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
          @form = form(AnswerForm).from_params(params, election:, question:)

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

        def select
          change_selected(true)
        end

        def unselect
          change_selected(false)
        end

        def change_selected(selected)
          enforce_permission_to :select, :answer, election: election, question: question

          UpdateAnswerSelection.call(answer, selected) do
            on(:ok) do
              flash[:notice] = if selected
                                 I18n.t("answers.select.success", scope: "decidim.elections.admin")
                               else
                                 I18n.t("answers.unselect.success", scope: "decidim.elections.admin")
                               end
            end

            on(:invalid) do
              flash.now[:alert] = if selected
                                    I18n.t("answers.select.invalid", scope: "decidim.elections.admin")
                                  else
                                    I18n.t("answers.unselect.invalid", scope: "decidim.elections.admin")
                                  end
            end
          end

          redirect_to election_question_answers_path(election, question)
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

        def missing_answers
          question.max_selections - answers.count
        end
      end
    end
  end
end
