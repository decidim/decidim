# frozen_string_literal: true

module Decidim
  module Votings
    # This query selects the promoted votings
    class OrganizationPromotedVotings < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Votings::Voting.where(organization: @organization).promoted
      end
    end
  end
end
