# frozen_string_literal: true

module Decidim
  module Votings
    # This query class filters votings given a current_user.
    class VisibleVotings < Rectify::Query
      def query
        Decidim::Votings::Voting.public_spaces
      end
    end
  end
end
