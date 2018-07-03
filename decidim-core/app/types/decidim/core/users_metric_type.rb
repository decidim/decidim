# frozen_string_literal: true

module Decidim
  module Core
    UsersMetricType = GraphQL::ObjectType.define do
      interfaces [-> { UsersMetricInterface }]

      name "UserMetric"
      description "UserMetric data"
    end

    module UsersMetricTypeHelper
      include Decidim::Core::BaseMetricTypeHelper

      def self.base_scope(organization, type = :count)
        Rails.cache.fetch("users_metric/#{organization.try(:id)}/#{type}", expires_in: 24.hours) do
          query = Decidim::User.where(organization: organization).confirmed.not_managed
          base_metric_scope(query, :confirmed_at, type)
        end
      end
    end
  end
end
