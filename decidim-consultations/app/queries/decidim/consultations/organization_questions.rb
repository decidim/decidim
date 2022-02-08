# frozen_string_literal: true

module Decidim
  module Consultations
    # This query class filters all questions given an organization.
    class OrganizationQuestions < Decidim::Query
      def self.for(organization)
        new(organization).query
      end

      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::Consultations::Question.where(organization: @organization)
      end
    end
  end
end
