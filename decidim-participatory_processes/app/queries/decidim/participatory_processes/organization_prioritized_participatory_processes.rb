# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters public processes given an organization in a
    # meaningful prioritized order.
    class OrganizationPrioritizedParticipatoryProcesses < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Rectify::Query.merge(
          OrganizationPublishedParticipatoryProcesses.new(@organization),
          PrioritizedParticipatoryProcesses.new
        ).query
      end
    end
  end
end
