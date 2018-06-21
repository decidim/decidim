# frozen_string_literal: true

module Decidim
  module Core
    MetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { MetricObjectInterface }]

      name "MetricObject"
      description "Metric object data"
    end
  end
end
