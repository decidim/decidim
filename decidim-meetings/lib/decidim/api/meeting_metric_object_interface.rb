# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingMetricObjectInterface = GraphQL::InterfaceType.define do
      name "MeetingMetricObjectInterface"
      description "MeetingMetric object definition"

      field :created_at, !types.String, "Created at date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:created_at) }
      end

      field :start_time, !types.String, "Start time" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:start_time) }
      end

      field :end_time, !types.String, "End time" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:end_time) }
      end

      field :scope, !types.String, "Meeting scope" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj.scope).attr_translated(:name) }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
