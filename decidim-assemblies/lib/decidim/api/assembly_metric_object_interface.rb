# frozen_string_literal: true

module Decidim
  module Assemblies
    AssemblyMetricObjectInterface = GraphQL::InterfaceType.define do
      name "AssemblyMetricObjectInterface"
      description "AssemblyMetric object definition"

      field :title, !types.String, "Assembly name" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_translated(:title) }
      end

      field :created_at, !types.String, "Created at date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:created_at) }
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
