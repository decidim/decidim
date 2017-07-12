# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
  # This query class filters published processes given an organization.
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
end
