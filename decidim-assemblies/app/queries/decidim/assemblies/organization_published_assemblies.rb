# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query class filters published assemblies given an organization.
    class OrganizationPublishedAssemblies < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Rectify::Query.merge(
          OrganizationAssemblies.new(@organization),
          PublishedAssemblies.new
        ).query
      end
    end
  end
end
