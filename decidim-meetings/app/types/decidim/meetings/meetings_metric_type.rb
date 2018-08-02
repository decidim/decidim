# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "MeetingsMetricType"
      description "A meeting component of a participatory space."
    end
  end
end
