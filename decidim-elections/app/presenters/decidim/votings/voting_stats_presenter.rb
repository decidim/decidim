# frozen_string_literal: true

module Decidim
  module Votings
    # A presenter to render statistics in a Voting.
    class VotingStatsPresenter < Decidim::StatsPresenter
      include Decidim::IconHelper

      def voting
        __getobj__.fetch(:voting)
      end

      def participatory_space
        voting
      end

      def participatory_space_sym
        :votings
      end
    end
  end
end
