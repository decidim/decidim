# frozen_string_literal: true

module Decidim
  module Core
    UsersMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { UsersMetricObjectInterface }]

      name "UsersMetricObject"
      description "UsersMetric object data"
    end
  end
end
