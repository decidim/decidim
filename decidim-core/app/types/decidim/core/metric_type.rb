# frozen_string_literal: true

module Decidim
  module Core
    class MetricType< GraphQL::Schema::Object
      graphql_name   "MetricType"
      description "Metric data"

      field :name, String,null: false, description:  "The name of the metric"
      field :count, Int,null: false, description:  "The last value of the metric"
      field :history, [MetricHistoryType],null: false, description:  "The historic values for this metric"
    end
  end
end
