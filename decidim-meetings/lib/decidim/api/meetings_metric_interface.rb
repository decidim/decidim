# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingsMetricInterface = GraphQL::InterfaceType.define do
      name "MeetingsMetricInterface"
      description "MeetingsMetric definition"

      field :count, !types.Int, "Total meetings" do
        resolve ->(_obj, _args, ctx) {
          MeetingsMetricTypeHelper.base_scope(ctx[:current_organization], :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(_obj, _args, ctx) {
          MeetingsMetricTypeHelper.base_scope(ctx[:current_organization], :metric)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
