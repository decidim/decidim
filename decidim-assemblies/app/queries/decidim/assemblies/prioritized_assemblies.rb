# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query orders assemblies by importance, prioritizing promoted
    # assemblies.
    class PrioritizedAssemblies < Decidim::Query
      def query
        Decidim::Assembly.order(promoted: :desc)
      end
    end
  end
end
