# frozen_string_literal: true

module Decidim
  module Elections
    # Provides access to election resources so that users can participate Election.where(component: current_component).published.lections.
    class VotesController < Decidim::Elections::ApplicationController
      include Decidim::Elections::UsesVotesBooth
      include Decidim::FormFactory

      before_action do
        redirect_to new_election_per_question_vote_path(election) if election.per_question?
      end

      # Show the voting form for the given question
      def show; end

      # Saves the vote for the current question and redirect to the next question
      def update
        votes_buffer[question.id.to_s] = params.dig(:response, question.id.to_s)
        redirect_to next_vote_step_path
      end

      # Shows the confirmation page with the votes that will be cast
      def confirm; end

      # Casts the votes that have been saved in the session and redirects to the receipt page
      def cast
        CastVotes.call(election, votes_buffer, voter_uid) do
          on(:ok) do
            votes_buffer.clear
            session[:voter_uid] = voter_uid
            session_attributes.clear
            redirect_to receipt_election_votes_path(election), notice: t("votes.cast.success", scope: "decidim.elections")
          end

          on(:invalid) do
            redirect_to confirm_election_votes_path(election), alert: I18n.t("votes.cast.invalid", scope: "decidim.elections")
          end
        end
      end

      # Shows the receipt page
      def receipt
        enforce_permission_to(:create, :vote, election:)

        votes_buffer.clear
        session_attributes.clear
        redirect_to(exit_path) unless election.votes.exists?(voter_uid: session[:voter_uid])
      end

      private

      def next_vote_step_path
        return confirm_election_votes_path(election) unless question&.next_question

        election_vote_path(election, id: question.next_question)
      end
    end
  end
end
