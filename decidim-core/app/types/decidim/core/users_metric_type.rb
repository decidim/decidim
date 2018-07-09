# frozen_string_literal: true

module Decidim
  module Core
    UsersMetricType = GraphQL::ObjectType.define do
      interfaces [-> { UsersMetricInterface }]

      name "UserMetric"
      description "UserMetric data"
    end

    module UsersMetricTypeHelper
      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("users_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          Decidim::Metrics::UsersMetricCount.for(organization, counter_type: type)
        end
      end
    end
  end
end
