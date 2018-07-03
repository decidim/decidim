# frozen_string_literal: true

module Decidim
  module Assemblies
    AssembliesMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Assemblies::AssembliesMetricInterface }]

      name "AssembliesMetricType"
      description "An assembly component of a participatory space."
    end

    module AssembliesMetricTypeHelper
      include Decidim::Core::BaseMetricTypeHelper

      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("assemblies_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          query = Assembly.includes(:scope, :area).published
          base_metric_scope(query, :published_at, type)
        end
      end
    end
  end
end
