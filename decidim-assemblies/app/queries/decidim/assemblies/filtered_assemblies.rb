# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query filters assemblies by type.
    class FilteredAssemblies < Rectify::Query
      def initialize(filter)
        @filter = filter
      end

      def assemblies
        Decidim::Assembly
      end

      def query
        return assemblies.all if @filter.blank?

        assemblies.where(decidim_assemblies_type_id: @filter)
      end
    end
  end
end
