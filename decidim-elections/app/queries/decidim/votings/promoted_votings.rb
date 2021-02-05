# frozen_string_literal: true

module Decidim
  module Votings
    # This query selects the promoted votings
    class PromotedVotings < Rectify::Query
      def query
        Decidim::Votings::Voting.promoted
      end
    end
  end
end
