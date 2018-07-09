# frozen_string_literal: true

module Decidim
  module Assemblies
    AssembliesMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Assemblies::AssembliesMetricInterface }]

      name "AssembliesMetricType"
      description "An assembly component of a participatory space."
    end

    module AssembliesMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("assemblies_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          Decidim::Assemblies::Metrics::AssembliesMetricCount.for(organization, counter_type: type)
        end
      end
    end
  end
end
