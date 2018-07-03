# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingsMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { MeetingsMetricObjectInterface }]

      name "MeetingsMetricObject"
      description "MeetingsMetric object data"
    end
  end
end
