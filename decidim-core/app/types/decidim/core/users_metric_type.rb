# frozen_string_literal: true

module Decidim
  module Core
    UsersMetricType = GraphQL::ObjectType.define do
      interfaces [-> { UsersMetricInterface }]

      name "UserMetric"
      description "UserMetric data"
    end
  end
end
