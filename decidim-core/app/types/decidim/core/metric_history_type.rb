# frozen_string_literal: true

module Decidim
  module Core
    class MetricHistoryType< GraphQL::Schema::Object
      graphql_name  "MetricHistory"

      field :key, String, null: false, description: "The key value"
      field :value, Int, null: false, description: "The value for each key"

      def key
        MetricObjectPresenter.new(object).attr_date(0)
      end

      def value
        MetricObjectPresenter.new(object).attr_int(1)
      end
    end
  end
end
