# frozen_string_literal: true

module Decidim
  module Consultations
    class QuestionMultipleVotesController < Decidim::Consultations::ApplicationController
      layout "layouts/decidim/question_multivote"
      include NeedsQuestion
      include Decidim::FormFactory

      helper QuestionsHelper

      before_action :authenticate_user!

      # Non-ajax votings (such as multi-reponses) have a html page
      def show
        enforce_permission_to :vote, :question, question: current_question
        @form = form(VoteForm).from_model(current_question)
      end

      def create
        enforce_permission_to :vote, :question, question: current_question

        vote_forms = []
        params[:responses].each do |k,v|
          vote_forms << form(VoteForm).from_params({decidim_consultations_response_id: k}, current_question: current_question)
        end
        p '//////////////////'
        p vote_forms
        p '//////////////////'
        MultipleVoteQuestion.call(vote_forms) do
          on(:ok) do
            current_question.reload
            redirect_to question_question_votes_path
          end

          on(:invalid) do
            p "ERROROOOOOOOORRRRR"
            p vote_forms
            p "ERROROOOOOOOORRRRR"
            flash[:error] = I18n.t("question_votes.create.error", scope: "decidim.consultations")
            redirect_to question_question_multiple_votes_path
          end
        end
      end

      # TODO
      def destroy
        enforce_permission_to :unvote, :question, question: current_question
        UnvoteQuestion.call(current_question, current_user) do
          on(:ok) do
            current_question.reload
            redirect_to question_question_multiple_votes_path
          end
        end
      end
    end
  end
end
