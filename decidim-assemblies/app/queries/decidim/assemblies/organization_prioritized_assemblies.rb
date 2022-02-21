# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query class filters public assemblies given an organization in a
    # meaningful prioritized order.
    class OrganizationPrioritizedAssemblies < Decidim::Query
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def query
        Decidim::Query.merge(
          OrganizationPublishedAssemblies.new(@organization, @user),
          PrioritizedAssemblies.new
        ).query
      end
    end
  end
end
