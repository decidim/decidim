# frozen_string_literal: true

module Decidim
  module Core
    UserMetricType = GraphQL::ObjectType.define do
      name "UserMetric"
      description "User Metric Type"

      field :result, DataVizzType, "The current decidim's version of this deployment." do
        resolve ->(obj, _args, _ctx) { obj.collect(&:confirmed_at) }
      end
    end
  end
end
