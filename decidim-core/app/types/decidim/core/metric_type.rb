# frozen_string_literal: true

module Decidim
  module Core
    class MetricType < Decidim::Api::Types::BaseObject
      description "Metric data"

      field :name, GraphQL::Types::String, "The graphql_name of the metric", null: false
      field :count, GraphQL::Types::Int, "The last value of the metric", null: false
      field :history, [MetricHistoryType, { null: true }], "The historic values for this metric", null: false
    end
  end
end
