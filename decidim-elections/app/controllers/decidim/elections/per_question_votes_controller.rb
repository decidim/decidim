# frozen_string_literal: true

module Decidim
  module Elections
    # Provides access to election resources so that users can participate Election.where(component: current_component).published.lections.
    class PerQuestionVotesController < Decidim::Elections::ApplicationController
      include Decidim::Elections::UsesVotesBooth
      include Decidim::FormFactory

      before_action do
        redirect_to Decidim::EngineRouter.main_proxy(current_component).new_election_vote_path(election) unless election.per_question?
      end

      before_action only: :receipt do
        redirect_to(action: :waiting) if waiting_for_next_question?
      end

      before_action only: [:show, :update] do
        redirect_to(**next_vote_step_action) unless question.voting_enabled?
      end

      # Show the voting form for the given question
      def show
        enforce_permission_to(:create, :vote, election:)
      end

      # Saves the vote for the current question and redirect to the next question
      def update
        enforce_permission_to(:create, :vote, election:)

        response_ids = params.dig(:response, question.id.to_s)
        votes_buffer[question.id.to_s] = response_ids
        CastVotes.call(election, { question.id.to_s => response_ids }, voter_uid) do
          on(:ok) do
            session[:voter_uid] = voter_uid
            flash[:notice] = t("votes.cast.success", scope: "decidim.elections")
            redirect_to(**next_vote_step_action)
          end

          on(:invalid) do
            action = { action: :show, id: question }
            action = next_vote_step_action unless question.voting_enabled?

            flash[:alert] = t("votes.cast.invalid", scope: "decidim.elections")
            redirect_to(**action)
          end
        end
      end

      # If the election is per-question, this action will be called to show the waiting page
      # while the user waits for the next question to be available.
      # If the election is not per-question, this action will redirect to the next question
      def waiting
        enforce_permission_to(:create, :vote, election:)

        redirect_action = waiting_for_next_question? ? nil : next_vote_step_action
        respond_to do |format|
          format.html do
            redirect_to(**redirect_action) if redirect_action.present?
          end

          format.json do
            render json: { url: redirect_action ? url_for(**redirect_action) : nil }
          end
        end
      end

      private

      # we cannot memoize this method because it can change during the voting process
      def session_pending_questions
        election.questions.unpublished_results.where.not(id: votes_buffer.keys)
      end

      def waiting_for_next_question?
        session_pending_questions.any? && session_pending_questions.enabled.none?
      end

      def next_vote_step_action
        return { action: :receipt } unless session_pending_questions.any?

        next_question = session_pending_questions.enabled.first.presence || question.next_question.presence
        return { action: :waiting } if next_question.blank?

        { action: :show, id: next_question }
      end
    end
  end
end
