# frozen_string_literal: true

module Decidim
  module Core
    MetricHistoryType = GraphQL::ObjectType.define do
      name "MetricHistory"

      field :key, !types.String, "The key value" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(0) }
      end

      field :value, !types.Int, "The value for each key" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_int(1) }
      end
    end
  end
end
