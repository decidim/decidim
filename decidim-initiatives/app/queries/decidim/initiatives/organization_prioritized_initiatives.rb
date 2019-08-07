# frozen_string_literal: true

module Decidim
  module Initiatives
    # This query retrieves the organization prioritized initiatives that will appear in the homepage
    class OrganizationPrioritizedInitiatives < Rectify::Query
      attr_reader :organization

      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Initiative.where(organization: organization).published.open
      end
    end
  end
end
