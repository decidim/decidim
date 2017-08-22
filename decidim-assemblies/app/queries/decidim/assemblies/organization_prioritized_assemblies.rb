# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query class filters public assemblies given an organization in a
    # meaningful prioritized order.
    class OrganizationPrioritizedAssemblies < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Rectify::Query.merge(
          OrganizationPublishedAssemblies.new(@organization),
          PrioritizedAssemblies.new
        ).query
      end
    end
  end
end
