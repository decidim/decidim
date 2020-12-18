# frozen_string_literal: true

module Decidim
  module Initiatives
    # This query retrieves the organization prioritized initiatives that will appear in the homepage
    class OrganizationPrioritizedInitiatives < Rectify::Query
      attr_reader :organization, :order

      def initialize(organization, order = nil)
        @organization = organization
        @order = order
      end

      def query
        return base_query unless order

        base_query.order_by_most_recently_published
      end

      private

      def base_query
        Decidim::Initiative.where(organization: organization).published.open
      end
    end
  end
end
