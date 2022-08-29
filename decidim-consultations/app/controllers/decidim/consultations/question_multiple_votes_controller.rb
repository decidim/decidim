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
        @form = form(MultiVoteForm).instance(current_question:)
      end

      def create
        enforce_permission_to :vote, :question, question: current_question

        multivote_form = form(MultiVoteForm).from_params(params, current_question:)

        MultipleVoteQuestion.call(multivote_form, current_user) do
          on(:ok) do
            redirect_to question_path(current_question)
          end

          on(:invalid) do |_form, error|
            flash[:error] = I18n.t("question_votes.create.error", scope: "decidim.consultations")
            flash[:error] << " (#{error})" if error
            redirect_to question_question_multiple_votes_path
          end
        end
      end
    end
  end
end
