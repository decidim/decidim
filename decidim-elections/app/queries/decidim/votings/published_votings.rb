# frozen_string_literal: true

module Decidim
  module Votings
    # This query filters published votings only.
    class PublishedVotings < Decidim::Query
      def query
        Decidim::Votings::Voting.published
      end
    end
  end
end
