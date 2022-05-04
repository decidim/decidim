# frozen_string_literal: true

module Decidim
  module Votings
    # This query class filters published votings given an organization.
    class OrganizationPublishedVotings < Decidim::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Query.merge(
          OrganizationVotings.new(@organization),
          PublishedVotings.new
        ).query
      end
    end
  end
end
