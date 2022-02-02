# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query class filters published assemblies given an organization.
    class OrganizationPublishedAssemblies < Decidim::Query
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def query
        Decidim::Query.merge(
          OrganizationAssemblies.new(@organization),
          PublishedAssemblies.new,
          VisibleAssemblies.new(@user)
        ).query.order(weight: :asc)
      end
    end
  end
end
