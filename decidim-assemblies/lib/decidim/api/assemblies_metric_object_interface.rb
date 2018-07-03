# frozen_string_literal: true

module Decidim
  module Assemblies
    AssembliesMetricObjectInterface = GraphQL::InterfaceType.define do
      name "AssembliesMetricObjectInterface"
      description "AssembliesMetric object definition"

      field :title, !types.String, "Assembly name" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_translated(:title) }
      end

      field :published_at, !types.String, "Published at date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:published_at) }
      end

      field :scope, !types.String, "Assembly scope" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj.scope).attr_translated(:name) }
      end

      field :area, !types.String, "Assembly area" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj.area).attr_translated(:name) }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
