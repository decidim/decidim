# frozen_string_literal: true

module Decidim
  # This query class returns the Participatory Processes given an Organization.
  class OrganizationPublishedParticipatoryProcesses < Rectify::Query
    def initialize(organization)
      @organization = organization
    end

    def query
      Rectify::Query.merge(
        OrganizationParticipatoryProcesses.new(@organization),
        PublishedParticipatoryProcesses.new
      ).query
    end
  end
end
