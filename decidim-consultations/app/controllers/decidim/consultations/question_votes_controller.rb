# frozen_string_literal: true

module Decidim
  module Consultations
    class QuestionVotesController < Decidim::Consultations::ApplicationController
      include NeedsQuestion
      include Decidim::FormFactory

      helper QuestionsHelper

      before_action :authenticate_user!

      def create
        enforce_permission_to :vote, :question, question: current_question

        vote_form = form(VoteForm).from_params(params, current_question:)
        VoteQuestion.call(vote_form) do
          on(:ok) do
            current_question.reload
            render :update_vote_button
          end

          on(:invalid) do
            render json: {
              error: I18n.t("question_votes.create.error", scope: "decidim.consultations")
            }, status: :unprocessable_entity
          end
        end
      end

      def destroy
        enforce_permission_to :unvote, :question, question: current_question
        UnvoteQuestion.call(current_question, current_user) do
          on(:ok) do
            current_question.reload
            render :update_vote_button
          end
        end
      end
    end
  end
end
