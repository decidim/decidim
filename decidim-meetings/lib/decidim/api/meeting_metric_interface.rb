# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingMetricInterface = GraphQL::InterfaceType.define do
      name "MeetingMetricInterface"
      description "MeetingMetric definition"

      field :count, !types.Int, "Total meetings"

      field :data, !types[MeetingMetricObjectType], "Data for each meeting"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
