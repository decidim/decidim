# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    ParticipatoryProcessesMetricObjectInterface = GraphQL::InterfaceType.define do
      name "ParticipatoryProcessesMetricObjectInterface"
      description "ParticipatoryProcessesMetric object definition"

      field :title, !types.String, "ParticipatoryProcess title" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_translated(:title) }
      end

      field :created_at, !types.String, "Created at date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:created_at) }
      end

      field :scope, !types.String, "ParticipatoryProcess scope" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj.scope).attr_translated(:name) }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
