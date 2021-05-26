# frozen_string_literal: true

module Decidim
  module Votings
    # This query orders votings by importance, prioritizing promoted
    # votings.
    class PrioritizedVotings < Rectify::Query
      def query
        Decidim::Votings::Voting.order(promoted: :desc)
      end
    end
  end
end
