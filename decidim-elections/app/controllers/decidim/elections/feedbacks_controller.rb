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

      # Redirection after answering the questionnaire.
      def after_answer_path
        if current_user.nil?
          election_path(election, onboarding: true)
        else
          election_path(election, onboarding: false)
        end
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
