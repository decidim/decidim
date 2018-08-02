# frozen_string_literal: true

module Decidim
  module Accountability
    ResultsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "ResultsMetricType"
      description "A result metric object of a participatory space."
    end
  end
end
