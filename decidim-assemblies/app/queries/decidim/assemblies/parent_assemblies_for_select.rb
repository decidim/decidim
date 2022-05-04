# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query filters assemblies that can be assigned as parents for an assembly.
    class ParentAssembliesForSelect < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      def self.for(organization, assembly)
        new(organization, assembly).query
      end

      # Initializes the class.
      def initialize(organization, assembly)
        @organization = organization
        @assembly = assembly
      end

      # Finds the available assemblies
      #
      # Returns an ActiveRecord::Relation.
      def query
        available_assemblies = Assembly.where(organization: @organization).where.not(id: @assembly)

        return available_assemblies if @assembly.blank?

        available_assemblies.where.not(id: descendant_ids)
      end

      private

      def descendant_ids
        recursive_children(@assembly).flatten
      end

      def recursive_children(model)
        model.children.map do |child|
          [recursive_children(child), child.id]
        end
      end
    end
  end
end
