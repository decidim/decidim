# frozen_string_literal: true

module Decidim
  module Initiatives
    # Class used to know which initiative types have initiatives through any of
    # their scopes.
    #
    # It resolves everything in a single batched query, so callers that need to
    # check every initiative type (like the admin index) do not materialize the
    # initiatives of every type.
    class InitiativeTypesWithInitiatives < Decidim::Query
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

      # Retrieves the ids of the initiative types that have at least one
      # initiative in any of their scopes.
      def query
        Decidim::InitiativesTypeScope
          .joins(:initiatives)
          .where(type: InitiativeTypes.for(@organization))
          .distinct
          .pluck(:decidim_initiatives_types_id)
      end
    end
  end
end
