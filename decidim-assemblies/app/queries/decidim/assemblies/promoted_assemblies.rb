# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query filters assemblies so only promoted ones are returned.
    class PromotedAssemblies < Rectify::Query
      def query
        Decidim::Assembly.promoted
      end
    end
  end
end
