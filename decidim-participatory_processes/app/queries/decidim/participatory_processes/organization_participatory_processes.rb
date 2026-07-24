# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters all processes given an organization.
    class OrganizationParticipatoryProcesses < Decidim::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::ParticipatoryProcess.includes(:hero_image_attachment, :active_step).where(organization: @organization).order(weight: :asc)
      end
    end
  end
end
