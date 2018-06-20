# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingMetricObjectInterface = GraphQL::InterfaceType.define do
      name "MeetingMetricObjectInterface"
      description "MeetingMetric object definition"

      field :created_at, !types.String, "Created at date" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj).attr_date(:created_at) }
      end

      field :scope, !types.String, "Meeting scope" do
        resolve ->(obj, _args, _ctx) { MetricObjectPresenter.new(obj.scope).attr_translated(:name) }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
