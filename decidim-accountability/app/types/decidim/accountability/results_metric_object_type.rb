# frozen_string_literal: true

module Decidim
  module Accountability
    ResultsMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { ResultsMetricObjectInterface }]

      name "ResultsMetricObjec"
      description "ResultsMetric object data"
    end
  end
end
