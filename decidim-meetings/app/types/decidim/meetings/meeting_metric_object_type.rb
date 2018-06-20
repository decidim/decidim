# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { MeetingMetricObjectInterface }]

      name "MeetingMetricObject"
      description "MeetingMetric object data"
    end
  end
end
