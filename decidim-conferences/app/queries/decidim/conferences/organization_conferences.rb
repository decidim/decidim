# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters all conferences given an organization.
    class OrganizationConferences < Decidim::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Conference.where(organization: @organization).order(weight: :asc, start_date: :desc)
      end
    end
  end
end
