# frozen_string_literal: true

module Decidim
  # This query class returns the public Participatory Processes given an
  # Organization in a meaningful order.
  class OrganizationPrioritizedParticipatoryProcesses < Rectify::Query
    def initialize(organization)
      @organization = organization
    end

    def query
      Rectify::Query.merge(
        OrganizationParticipatoryProcesses.new(@organization),
        PrioritizedParticipatoryProcesses.new
      ).query
    end
  end
end
