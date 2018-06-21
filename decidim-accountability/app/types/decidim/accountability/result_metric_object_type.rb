# frozen_string_literal: true

module Decidim
  module Accountability
    ResultMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { ResultMetricObjectInterface }]

      name "ResultMetricObjec"
      description "ResultMetric object data"
    end
  end
end
