# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query filters assemblies so only parent assemblies are returned.
    class ParentAssemblies < Rectify::Query
      def query
        Decidim::Assembly.where(parent: nil)
      end
    end
  end
end
