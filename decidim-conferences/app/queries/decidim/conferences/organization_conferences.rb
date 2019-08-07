# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters all conferences given an organization.
    class OrganizationConferences < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Conference.where(organization: @organization)
      end
    end
  end
end
