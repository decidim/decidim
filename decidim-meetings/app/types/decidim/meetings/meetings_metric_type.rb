# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Meetings::MeetingsMetricInterface }]

      name "MeetingsMetricType"
      description "A meeting component of a participatory space."
    end

    module MeetingsMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("meetings_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          Decidim::Meetings::Metrics::MeetingsMetricCount.for(organization, counter_type: type)
        end
      end
    end
  end
end
