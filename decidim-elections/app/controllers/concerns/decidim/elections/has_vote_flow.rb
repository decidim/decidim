# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Elections
    # Common logic for the vote flow
    module HasVoteFlow
      extend ActiveSupport::Concern

      included do
        helper_method :voter_id, :voter_token, :voter_name, :preview_mode?
        delegate :voter_id, :voter_token, :voter_name, :email, to: :vote_flow
      end

      def vote_flow
        @vote_flow ||= if current_participatory_space.is_a? Decidim::Votings::Voting
                         Decidim::Votings::CensusVoteFlow.new(election, self)
                       else
                         Decidim::Elections::CurrentUserVoteFlow.new(election, self)
                       end
      end

      def preview_mode?
        return @preview_mode if defined?(@preview_mode)

        @preview_mode = !election.published? || !election.started?
      end

      def can_preview?
        return @can_preview if defined?(@can_preview)

        @preview_mode = allowed_to?(:preview, :election, election: election)
      end
    end
  end
end
