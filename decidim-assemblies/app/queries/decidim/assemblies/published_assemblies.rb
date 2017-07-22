# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query filters published assemblies only.
    class PublishedAssemblies < Rectify::Query
      def query
        Decidim::Assembly.published
      end
    end
  end
end
