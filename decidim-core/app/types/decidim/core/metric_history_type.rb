# frozen_string_literal: true

module Decidim
  module Core
    class MetricHistoryType < Decidim::Api::Types::BaseObject
      field :key, GraphQL::Types::String, "The key value", null: false
      field :value, GraphQL::Types::Int, "The value for each key", null: false

      def key
        MetricObjectPresenter.new(object).attr_date(0)
      end

      def value
        MetricObjectPresenter.new(object).attr_int(1)
      end
    end
  end
end
