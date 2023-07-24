# frozen_string_literal: true

module Decidim
  module Votings
    # This cell renders the card for an instance of a Voting
    # the default size is the Search Card (:s)
    class VotingCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :s
          "decidim/votings/voting_s"
        else
          "decidim/votings/voting_g"
        end
      end
    end
  end
end
