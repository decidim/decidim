# frozen_string_literal: true

module Decidim
  module Core
    class MetricType < Decidim::Api::Types::BaseObject
      graphql_name "MetricType"
      description "Metric data"

      field :name, String, "The graphql_name of the metric", null: false
      field :count, Integer, "The last value of the metric", null: false
      field :history, [MetricHistoryType, { null: true }], "The historic values for this metric", null: false
    end
  end
end
