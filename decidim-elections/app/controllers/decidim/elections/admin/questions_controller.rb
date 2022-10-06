# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows the create or update questions for an election.
      class QuestionsController < Admin::ApplicationController
        helper_method :election, :questions, :question

        def new
          enforce_permission_to :create, :question, election: election
          @form = form(QuestionForm).instance
        end

        def create
          enforce_permission_to :create, :question, election: election
          @form = form(QuestionForm).from_params(params, election:)

          CreateQuestion.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("questions.create.success", scope: "decidim.elections.admin")
              redirect_to election_questions_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questions.create.invalid", scope: "decidim.elections.admin")
              render action: "new"
            end

            on(:election_started) do
              flash.now[:alert] = I18n.t("questions.create.election_started", scope: "decidim.elections.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :question, election: election, question: question
          @form = form(QuestionForm).from_model(question)
        end

        def update
          enforce_permission_to :update, :question, election: election, question: question
          @form = form(QuestionForm).from_params(params, election:)

          UpdateQuestion.call(@form, question) do
            on(:ok) do
              flash[:notice] = I18n.t("questions.update.success", scope: "decidim.elections.admin")
              redirect_to election_questions_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questions.update.invalid", scope: "decidim.elections.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :update, :question, election: election, question: question

          DestroyQuestion.call(question, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("questions.destroy.success", scope: "decidim.elections.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questions.destroy.invalid", scope: "decidim.elections.admin")
            end
          end

          redirect_to election_questions_path(election)
        end

        private

        def election
          @election ||= Election.where(component: current_component).find_by(id: params[:election_id])
        end

        def questions
          @questions ||= election.questions
        end

        def question
          questions.find(params[:id])
        end
      end
    end
  end
end
