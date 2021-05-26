# frozen_string_literal: true

module Decidim
  module Votings
    # This query class filters public votings given an organization in a
    # meaningful prioritized order.
    class OrganizationPrioritizedVotings < Rectify::Query
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def query
        Rectify::Query.merge(
          OrganizationPublishedVotings.new(@organization),
          PrioritizedVotings.new
        ).query
      end
    end
  end
end
