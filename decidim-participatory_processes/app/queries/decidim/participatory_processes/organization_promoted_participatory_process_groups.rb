# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory process groups given an organization.
    class OrganizationPromotedParticipatoryProcessGroups < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        PromotedParticipatoryProcessGroups.new.query.where(organization: @organization)
      end
    end
  end
end
