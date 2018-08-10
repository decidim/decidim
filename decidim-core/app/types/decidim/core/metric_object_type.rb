# frozen_string_literal: true

module Decidim
  module Core
    MetricObjectType = GraphQL::ObjectType.define do
      name "MetricObject"
      description "Metric object data"

      field :key, !types.String, "key" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(0) }
      end

      field :value, !types.Int, "value" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_int(1) }
      end
    end
  end
end
