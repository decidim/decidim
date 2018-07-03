# frozen_string_literal: true

module Decidim
  module Accountability
    ResultsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Accountability::ResultsMetricInterface }]

      name "ResultsMetricType"
      description "A result component of a participatory space."
    end

    module ResultsMetricTypeHelper
      include Decidim::Core::BaseMetricTypeHelper

      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("results_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          query = Result.includes(:category, :status)
          base_metric_scope(query, :created_at, type)
        end
      end
    end
  end
end
