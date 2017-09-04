# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters public processes given an organization and a
    # filter in a meaningful prioritized order.
    class OrganizationPrioritizedParticipatoryProcesses < Rectify::Query
      def initialize(organization, filter = "active")
        @organization = organization
        @filter = filter
      end

      def query
        Rectify::Query.merge(
          OrganizationPublishedParticipatoryProcesses.new(@organization),
          PrioritizedParticipatoryProcesses.new,
          FilteredParticipatoryProcesses.new(@filter)
        ).query
      end
    end
  end
end
