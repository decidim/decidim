# frozen_string_literal: true

module Decidim
  module Meetings
    module Metrics
      class MeetingsMetricCount < Decidim::MetricCount
        def self.for(organization, counter_type: :count, counter_field: :cumulative, group_by: :day)
          super(organization, "meetings", counter_type: counter_type, counter_field: counter_field, group_by: group_by)
        end
      end
    end
  end
end
