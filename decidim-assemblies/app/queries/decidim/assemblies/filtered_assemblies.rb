# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query filters assemblies by type.
    class FilteredAssemblies < Rectify::Query
      def initialize(filter)
        @filter = filter
      end

      def filter
        return "all" if @filter.nil?

        @filter
      end

      def assemblies
        Decidim::Assembly
      end

      def query
        return assemblies.all if filter == "all"

        assemblies.where(assembly_type: filter)
      end
    end
  end
end
