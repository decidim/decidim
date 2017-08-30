# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory process groups given an organization.
    class OrganizationPrioritizedParticipatoryProcessGroups < Rectify::Query
      def initialize(organization, filter = "active")
        @organization = organization
        @filter = filter
      end

      def query
        Rectify::Query.merge(
          OrganizationParticipatoryProcessGroups.new(@organization),
          FilteredParticipatoryProcessGroups.new(@filter)
        ).query
      end
    end
  end
end
