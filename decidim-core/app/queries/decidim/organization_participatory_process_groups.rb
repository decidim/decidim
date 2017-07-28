# frozen_string_literal: true

module Decidim
  # This query class returns the participatory process groups given an
  # Organization.
  class OrganizationParticipatoryProcessGroups < Rectify::Query
    def initialize(organization)
      @organization = organization
    end

    def query
      ParticipatoryProcessGroup.where(organization: @organization)
    end
  end
end
