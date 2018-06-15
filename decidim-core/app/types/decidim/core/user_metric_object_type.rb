# frozen_string_literal: true

module Decidim
  module Core
    UserMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { UserMetricObjectInterface }]

      name "UserMetricObject"
      description "UserMetric object data"
    end
  end
end
