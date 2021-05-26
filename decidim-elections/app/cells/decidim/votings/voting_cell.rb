# frozen_string_literal: true

module Decidim
  module Votings
    # This cell renders the card for an instance of a Voting
    # the default size is the Medium Card (:m)
    class VotingCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/votings/voting_m"
      end
    end
  end
end
