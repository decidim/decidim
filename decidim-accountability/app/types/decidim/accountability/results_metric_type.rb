# frozen_string_literal: true

module Decidim
  module Accountability
    ResultsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Accountability::ResultsMetricInterface }]

      name "ResultsMetricType"
      description "A result component of a participatory space."
    end

    module ResultsMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("results_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          Decidim::Accountability::Metrics::ResultsMetricCount.for(organization, counter_type: type)
        end
      end
    end
  end
end
