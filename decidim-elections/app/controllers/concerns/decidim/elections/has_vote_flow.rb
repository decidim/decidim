# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Elections
    # Common logic for the vote flow
    module HasVoteFlow
      extend ActiveSupport::Concern

      included do
        helper_method :voter_id, :voter_token, :voter_name, :preview_mode?, :ballot_style_id
        delegate :voter_id, :ballot_style_id, :voter_token, :voter_name, :email, to: :vote_flow
      end

      def vote_flow
        @vote_flow ||= election.participatory_space.try(:vote_flow_for, election) || default_vote_flow
      end

      def default_vote_flow
        Decidim::Elections::CurrentUserVoteFlow.new(election, current_user) do
          allowed_to?(:user_vote, :election, election:)
        end
      end

      def preview_mode?
        return @preview_mode if defined?(@preview_mode)

        @preview_mode = !election.published? || !election.started?
      end

      def can_preview?
        return @can_preview if defined?(@can_preview)

        @preview_mode = allowed_to?(:preview, :election, election:)
      end

      def ballot_questions
        vote_flow.questions_for(election)
      end
    end
  end
end
