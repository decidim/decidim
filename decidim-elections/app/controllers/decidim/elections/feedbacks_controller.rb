# frozen_string_literal: true

module Decidim
  module Elections
    # This controller allows a user to give feedback once finished voting
    class FeedbacksController < Decidim::Elections::ApplicationController
      include Decidim::Forms::Concerns::HasQuestionnaire
      include HasVoteFlow

      helper_method :election

      def questionnaire_for
        election
      end

      # where the questionnaire will be submitted.
      def update_url
        answer_election_feedback_path(election, hash: params[:hash], token: params[:token])
      end

      # Overwrites the 'after_answer_path' that gets passed to 'redirect_to'
      # after answering the questionnaire. By default it redirects to the questionnaire_for.
      def after_answer_path
        election_path(election, onboarding: current_user.nil?)
      end

      private

      def election
        @election ||= Election.where(component: current_component).includes(:questionnaire).find(params[:election_id])
      end

      def allow_answers?
        can_preview? || (election.ongoing? && valid_token?)
      end

      def visitor_already_answered?
        election.questionnaire.answered_by?(session_token)
      end

      def i18n_flashes_scope
        "decidim.elections.feedback"
      end

      def enforce_permission_to_answer_questionnaire
        can_preview? || valid_token?
      end

      def allow_unregistered?
        true
      end

      def valid_token?
        return @valid_token if defined?(@valid_token)

        @valid_token = vote_flow.voter_id_token(vote.voter_id) == session_token
      end

      def session_token
        @session_token ||= params[:token]
      end

      def vote
        @vote ||= Decidim::Elections::Vote.find_by(encrypted_vote_hash: params[:hash])
      end
    end
  end
end
