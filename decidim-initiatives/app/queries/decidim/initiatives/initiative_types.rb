# frozen_string_literal: true

module Decidim
  module Initiatives
    # Class uses to retrieve the available initiative types.
    class InitiativeTypes < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # organization - Decidim::Organization
      def self.for(organization)
        new(organization).query
      end

      # Initializes the class.
      #
      # organization - Decidim::Organization
      def initialize(organization)
        @organization = organization
      end

      # Retrieves the available initiative types for the given organization.
      def query
        InitiativesType.where(organization: @organization)
      end
    end
  end
end
