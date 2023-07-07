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

      # REDESIGN_PENDING: size :m is deprecated
      def card_size
        case @options[:size]
        when :s
          "decidim/votings/voting_s"
        when :m
          "decidim/votings/voting_m"
        else
          "decidim/votings/voting_g"
        end
      end
    end
  end
end
