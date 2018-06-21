# frozen_string_literal: true

module Decidim
  module Core
    MetricObjectInterface = GraphQL::InterfaceType.define do
      name "MetricObjectInterface"
      description "Metric object definition"

      field :key, !types.String, "key" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(0) }
      end

      field :value, !types.Int, "value" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_int(1) }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
