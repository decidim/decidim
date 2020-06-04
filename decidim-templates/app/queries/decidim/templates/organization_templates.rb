# frozen_string_literal: true

module Decidim
  module Templates
    # This query class filters all templates given an organization.
    class OrganizationTemplates < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Templates::Template.where(organization: @organization)
      end
    end
  end
end
