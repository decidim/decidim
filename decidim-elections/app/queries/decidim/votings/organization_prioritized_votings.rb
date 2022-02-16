# frozen_string_literal: true

module Decidim
  module Votings
    # This query class filters public votings given an organization in a
    # meaningful prioritized order.
    class OrganizationPrioritizedVotings < Decidim::Query
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def query
        Decidim::Query.merge(
          OrganizationPublishedVotings.new(@organization),
          PrioritizedVotings.new
        ).query
      end
    end
  end
end
