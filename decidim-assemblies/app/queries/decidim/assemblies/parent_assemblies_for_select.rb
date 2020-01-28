# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query filters assemblies that can be assigned as parents for an assembly.
    class ParentAssembliesForSelect < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      def self.for(organization, assembly)
        new(organization, assembly).query
      end

      # Initializes the class.
      def initialize(organization, assembly)
        @organization = organization
        @assembly = assembly
      end

      def query
        Assembly.where(organization: @organization).where.not(id: @assembly)
      end
    end
  end
end
