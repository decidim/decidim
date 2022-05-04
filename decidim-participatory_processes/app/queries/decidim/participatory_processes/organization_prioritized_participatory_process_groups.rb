# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory process groups given an organization and a filter.
    class OrganizationPrioritizedParticipatoryProcessGroups < Decidim::Query
      def initialize(organization, filter = "active", user = nil)
        @organization = organization
        @filter = filter
        @user = user
      end

      def query
        Decidim::Query.merge(
          OrganizationParticipatoryProcessGroups.new(@organization),
          FilteredParticipatoryProcessGroups.new(@filter),
          VisibleParticipatoryProcessGroups.new(@user)
        ).query
      end
    end
  end
end
