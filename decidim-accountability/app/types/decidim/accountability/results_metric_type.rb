# frozen_string_literal: true

module Decidim
  module Accountability
    ResultsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Accountability::ResultsMetricInterface }]

      name "ResultsMetricType"
      description "A result metric object of a participatory space."
    end

    module ResultsMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Decidim::Accountability::Metrics::ResultsMetricCount.for(organization, counter_type: type)
      end
    end
  end
end
