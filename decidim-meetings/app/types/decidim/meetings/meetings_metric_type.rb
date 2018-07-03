# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingsMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Meetings::MeetingsMetricInterface }]

      name "MeetingsMetricType"
      description "A meeting component of a participatory space."
    end

    module MeetingsMetricTypeHelper
      include Decidim::Core::BaseMetricTypeHelper

      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("meetings_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          query = Meeting.includes(:scope)
          base_metric_scope(query, :start_time, type)
        end
      end
    end
  end
end
