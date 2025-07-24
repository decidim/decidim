# frozen_string_literal: true

module Decidim
  module Elections
    # Provides access to election resources so that users can participate Election.where(component: current_component).published.lections.
    class PerQuestionVotesController < Decidim::Elections::ApplicationController
      include Decidim::Elections::UsesVotesBooth
      include Decidim::FormFactory

      before_action do
        redirect_to new_election_vote_path(election) unless election.per_question?
      end

      # Show the voting form for the given question
      def show
        redirect_to(waiting_election_per_question_votes_path(election_id: election)) if waiting_for_next_question?
      end

      # Saves the vote for the current question and redirect to the next question
      def update
        response_ids = params.dig(:response, question.id.to_s)
        CastVotes.call(election, { question.id.to_s => response_ids }, voter_uid) do
          on(:ok) do
            votes_buffer[question.id.to_s] = response_ids
            session[:voter_uid] = voter_uid
            flash[:notice] = t("votes.cast.success", scope: "decidim.elections")
            redirect_to next_vote_step_path
          end

          on(:invalid) do
            redirect_to(question_path(question), alert: t("votes.cast.invalid", scope: "decidim.elections"))
          end
        end
      end

      # If the election is per-question, this action will be called to show the waiting page
      # while the user waits for the next question to be available.
      # If the election is not per-question, this action will redirect to the next question
      def waiting
        redirect_path = waiting_for_next_question? ? nil : next_vote_step_path

        respond_to do |format|
          format.html do
            redirect_to(redirect_path) if redirect_path.present?
          end

          format.json do
            render json: { url: redirect_path }
          end
        end
      end

      # Shows the receipt page
      def receipt
        enforce_permission_to(:create, :vote, election:)
        return redirect_to(waiting_election_per_question_votes_path(election_id: election)) if waiting_for_next_question?

        @voter_uid = session[:voter_uid]
        votes_buffer.clear
        session_attributes.clear
        return redirect_to(exit_path) unless election.votes.exists?(voter_uid: @voter_uid)

        render "decidim/elections/votes/receipt"
      end

      private

      def waiting_for_next_question?
        return false unless election.per_question?

        pending_questions = election.questions.unpublished_results.where.not(id: election.votes.where(voter_uid: session[:voter_uid]).pluck(:question_id))

        pending_questions.any? && pending_questions.enabled.none?
      end

      def next_vote_step_path
        next_pending_question = if editing?
                                  question&.next_question
                                else
                                  questions.where.not(id: election.votes.where(voter_uid: voter_uid).pluck(:question_id)).first
                                end
        question_path(next_pending_question).presence || receipt_election_per_question_votes_path(election_id: election)
      end

      def question_path(question)
        options = {}.tap do |opts|
          opts[:edit] = "true" if editing?
        end
        return waiting_election_per_question_votes_path(election_id: election, **options) if waiting_for_next_question?

        return election_per_question_vote_path(election_id: election, id: question, **options) if question

        confirm_election_per_question_votes_path(election_id: election) unless election.per_question?
      end
    end
  end
end
