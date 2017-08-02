# frozen_string_literal: true

module Decidim
  # This query class filters all processes given an organization.
  class OrganizationParticipatoryProcesses < Rectify::Query
    def initialize(organization)
      @organization = organization
    end

    def query
      ParticipatoryProcess.where(organization: @organization)
    end
  end
end
