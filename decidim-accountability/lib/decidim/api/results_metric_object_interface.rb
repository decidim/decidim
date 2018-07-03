# frozen_string_literal: true

module Decidim
  module Accountability
    ResultsMetricObjectInterface = GraphQL::InterfaceType.define do
      name "ResultsMetricObjectInterface"
      description "ResultsMetric object definition"

      field :title, !types.String, "Result title" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_translated(:title) }
      end

      field :status, !types.String, "status" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj.status).attr_translated(:name) }
      end

      field :start_date, !types.String, "Start date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:start_date) }
      end

      field :end_date, !types.String, "End date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:end_date) }
      end

      field :created_at, !types.String, "Created at date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:created_at) }
      end

      field :category, !types.String, "Category" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj.category).attr_translated(:name) }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
