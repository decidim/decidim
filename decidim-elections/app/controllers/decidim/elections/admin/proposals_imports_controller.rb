# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows to import proposals as answers.
      class ProposalsImportsController < Admin::ApplicationController
        helper_method :election, :question, :answers, :answers

        def new
          enforce_permission_to :import_proposals, :answer, election: election, question: question
          @form = form(Admin::AnswerImportProposalsForm).instance
        end

        def create
          enforce_permission_to :import_proposals, :answer, election: election, question: question

          @form = form(Admin::AnswerImportProposalsForm).from_params(params, election:, question:)

          Admin::ImportProposalsToElections.call(@form) do
            on(:ok) do |answers|
              flash[:notice] = I18n.t("proposals_imports.create.success", scope: "decidim.elections.admin", number: answers.length)
              redirect_to election_question_answers_path(election, question)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("proposals_imports.create.invalid", scope: "decidim.elections.admin")
              render action: "new"
            end
          end
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
