# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingMetricInterface = GraphQL::InterfaceType.define do
      name "MeetingMetricInterface"
      description "MeetingMetric definition"

      field :count, !types.Int, "Total meetings" do
        resolve ->(organization, _args, _ctx) {
          MeetingMetricTypeHelper.base_scope(organization).count
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          MeetingMetricTypeHelper.base_scope(organization).group("date_trunc('day', start_time)").count
        }
      end

      field :data, !types[MeetingMetricObjectType], "Data for each meeting" do
        resolve ->(organization, _args, _ctx) {
          MeetingMetricTypeHelper.base_scope(organization)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
