# frozen_string_literal: true

module Decidim
  module Assemblies
    # This module is to extend the API with custom fields related to
    # decidim-assemblies' metrics.
    module QueryExtensions
      # Public: Extends a type with `decidim-assemblies`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.define(type)
        type.field :assembliesMetric, Assemblies::AssembliesMetricType, "Decidim's AssembliesMetric data." do
          resolve ->(_obj, _args, ctx) { Decidim::Assemblies::AssembliesMetricResolver.new(ctx[:current_organization]) }
        end
      end
    end
  end
end
