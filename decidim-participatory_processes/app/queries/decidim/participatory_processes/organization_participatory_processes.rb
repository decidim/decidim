# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters all processes given an organization.
    class OrganizationParticipatoryProcesses < Decidim::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::ParticipatoryProcess.with_attached_hero_image.includes(:active_step).where(organization: @organization).order(weight: :asc)
      end
    end
  end
end
