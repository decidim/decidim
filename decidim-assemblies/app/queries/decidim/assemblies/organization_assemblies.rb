# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query class filters all assemblies given an organization.
    class OrganizationAssemblies < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Assembly.where(organization: @organization).order(weight: :asc)
      end
    end
  end
end
