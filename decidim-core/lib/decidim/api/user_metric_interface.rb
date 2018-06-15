# frozen_string_literal: true

module Decidim
  module Core
    UserMetricInterface = GraphQL::InterfaceType.define do
      name "UserMetricInterface"
      description "UserMetric definition"

      field :count, !types.Int, "Total users"

      field :data, !types[UserMetricObjectType], "Data for each user"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
