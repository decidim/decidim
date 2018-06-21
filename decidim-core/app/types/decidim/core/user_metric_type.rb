# frozen_string_literal: true

module Decidim
  module Core
    UserMetricType = GraphQL::ObjectType.define do
      interfaces [-> { UserMetricInterface }]

      name "UserMetric"
      description "UserMetric data"
    end

    module UserMetricTypeHelper
      def self.base_scope(organization)
        Decidim::User.where(organization: organization).confirmed.not_managed
      end
    end
  end
end
