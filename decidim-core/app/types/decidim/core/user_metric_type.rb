# frozen_string_literal: true

module Decidim
  module Core
    UserMetricType = GraphQL::ObjectType.define do
      interfaces [-> { UserMetricInterface }]

      name "UserMetric"
      description "UserMetric data"

      field :count, !types.Int, "Total users" do
        resolve ->(organization, _args, _ctx) {
          UserMetricTypeHelper.base_scope(organization).count
        }
      end

      field :data, !types[UserMetricObjectType], "Data for each user" do
        resolve ->(organization, _args, _ctx) {
          UserMetricTypeHelper.base_scope(organization)
        }
      end
    end

    module UserMetricTypeHelper
      def self.base_scope(organization)
        Decidim::User.where(organization: organization).confirmed.not_managed
      end
    end
  end
end
