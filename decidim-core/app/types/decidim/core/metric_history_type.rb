# frozen_string_literal: true

module Decidim
  module Core
    class MetricHistoryType < Decidim::Api::Types::BaseObject

      field :key, String, "The key value", null: false

      def key
        MetricObjectPresenter.new(object).attr_date(0)
      end

      field :value, Integer, "The value for each key", null: false

      def value
        MetricObjectPresenter.new(object).attr_int(1)
      end
    end
  end
end
