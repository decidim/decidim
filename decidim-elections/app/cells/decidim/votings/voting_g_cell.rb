# frozen_string_literal: true

module Decidim
  module Votings
    # This cell renders the Grid (:g) voting card
    # for an given instance of a Voting
    class VotingGCell < Decidim::CardGCell
      private

      def metadata_cell
        "decidim/votings/voting_metadata"
      end
    end
  end
end
