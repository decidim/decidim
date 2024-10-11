# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query filters published assemblies only.
    class PublishedAssemblies < Decidim::Query
      def query
        Decidim::Assembly.published.not_trashed
      end
    end
  end
end
