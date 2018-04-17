# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters public processes given an organization and a
    # filter in a meaningful prioritized order.
    class OrganizationPrioritizedParticipatoryProcesses < Rectify::Query
      def initialize(organization, filter = "active", user = nil)
        @organization = organization
        @filter = filter
        @user = user
      end

      def query
        Rectify::Query.merge(
          OrganizationPublishedParticipatoryProcesses.new(@organization, @user),
          PrioritizedParticipatoryProcesses.new,
          FilteredParticipatoryProcesses.new(@filter)
        ).query
      end
    end
  end
end
