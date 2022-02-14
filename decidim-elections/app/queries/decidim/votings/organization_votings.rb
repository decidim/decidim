# frozen_string_literal: true

module Decidim
  module Votings
    # This query class filters all votings given an organization.
    class OrganizationVotings < Decidim::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Votings::Voting.where(organization: @organization)
      end
    end
  end
end
