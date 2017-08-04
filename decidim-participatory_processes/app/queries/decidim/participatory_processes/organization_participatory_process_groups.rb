# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory process groups given an organization.
    class OrganizationParticipatoryProcessGroups < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::ParticipatoryProcessGroup.where(organization: @organization)
      end
    end
  end
end
