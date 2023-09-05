# frozen_string_literal: true

module Decidim
  module Votings
    # A presenter to render statistics in a Voting.
    class VotingStatsPresenter < Decidim::StatsPresenter
      include Decidim::IconHelper

      private

      def participatory_space = __getobj__.fetch(:voting)

      def participatory_space_sym = :votings
    end
  end
end
