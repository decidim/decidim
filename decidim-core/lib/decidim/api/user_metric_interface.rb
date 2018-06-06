# frozen_string_literal: true

module Decidim
  module Core
    UserMetricInterface = GraphQL::InterfaceType.define do
      name "UserMetricInterface"
      description "UserMetricInterface"

      field :result, DataVizzType, "The current decidim's version of this deployment."

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
