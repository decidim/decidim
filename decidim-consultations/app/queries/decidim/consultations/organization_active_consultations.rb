# frozen_string_literal: true

module Decidim
  module Consultations
    # This query class filters all consultations given an organization.
    class OrganizationActiveConsultations < Rectify::Query
      def self.for(organization)
        new(organization).query
      end

      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Consultation.where(organization: @organization).active
      end
    end
  end
end
