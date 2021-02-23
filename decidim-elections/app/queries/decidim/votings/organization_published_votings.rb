# frozen_string_literal: true

module Decidim
  module Votings
    # This query class filters published votings given an organization.
    class OrganizationPublishedVotings < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Rectify::Query.merge(
          OrganizationVotings.new(@organization),
          PublishedVotings.new
        ).query
      end
    end
  end
end
