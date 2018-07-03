# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingsMetricInterface = GraphQL::InterfaceType.define do
      name "MeetingsMetricInterface"
      description "MeetingsMetric definition"

      field :count, !types.Int, "Total meetings" do
        resolve ->(organization, _args, _ctx) {
          MeetingsMetricTypeHelper.base_scope(organization, :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          MeetingsMetricTypeHelper.base_scope(organization, :metric)
        }
      end

      field :data, !types[MeetingsMetricObjectType], "Data for each meeting" do
        resolve ->(organization, _args, _ctx) {
          MeetingsMetricTypeHelper.base_scope(organization, :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
